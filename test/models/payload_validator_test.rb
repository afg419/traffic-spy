require_relative '../test_helper'

class PayloadValidatorTest < ModelTest
  def ruby_params_no_sha(i = nil)
    {"url"=>"blog#{i}",
     "requested_at"=>"2013-02-16 21:38:28 -0700",
     "responded_in"=>37,
     "referred_by"=>"http://jumpstartlab.com",
     "request_type"=>"GET",
     "event_name"=>"socialLogin",
     "resolution_width"=>"1920",
     "resolution_height"=>"1280",
     "ip"=>"63.29.38.211",
     "browser"=>"Chrome",
     "platform"=>"Macintosh"}
  end

  def default_identifier
    "jumpstartlab"
  end

  def default_root_url
    "http://jumpstartlab.com"
  end

  def test_class_exists
    assert TrafficSpy::PayloadValidator
  end

  def register_default_user
    register_user(default_identifier, default_root_url)
  end

  def test_returns_proper_messages_for_good_params
    register_default_user
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, default_identifier)

    assert_equal 200, validator.status
    assert_equal "Success - 200 OK", validator.body
  end

  def test_assigns_payload_to_correct_user
    register_default_user
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, default_identifier)

    assert_equal 200, validator.status
    assert_equal 1, TrafficSpy::Payload.all.first.user_id
  end

  def test_assigns_url_to_correct_user
    register_default_user
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, default_identifier)

    assert_equal 200, validator.status
    assert_equal 1, TrafficSpy::Payload.all.first.url_id
  end

  def test_assigns_object_to_correct_user_multiple_users
    register_default_user
    register_user("jumpstartlab1","http://jumpstartlab1.com")

    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, default_identifier)
    validator.insert_or_error_status(ruby_params_no_sha(1), "jumpstartlab1")
    validator.insert_or_error_status(ruby_params_no_sha(2), "jumpstartlab1")
    validator.insert_or_error_status(ruby_params_no_sha(3), default_identifier)

    first_urls = TrafficSpy::User.find_by(identifier: default_identifier).payloads.map{|x| x.url.url}
    second_urls = TrafficSpy::User.find_by(identifier:"jumpstartlab1").payloads.map{|x| x.url.url}

    assert_equal ["blog","blog3"], first_urls
    assert_equal ["blog1", "blog2"], second_urls
  end


  def test_returns_proper_messages_for_missing_params
    register_default_user

    key_to_delete = ruby_params_no_sha.keys.sample
    incomplete_params = ruby_params_no_sha.tap{|h| h.delete(key_to_delete)}
    validator = TrafficSpy::PayloadValidator.new

    validator.insert_or_error_status(incomplete_params, default_identifier)

    assert_equal 400, validator.status
    assert_equal "Missing Payload - 400 Bad Request", validator.body
  end

  def test_returns_proper_messages_for_duplicate_payload
    register_default_user

    validator = TrafficSpy::PayloadValidator.new
    ruby_params_sha = validator.prep_sha(ruby_params_no_sha)
    TrafficSpy::DbLoader.new(ruby_params_sha, default_identifier).load_databases
    validator.insert_or_error_status(ruby_params_no_sha, default_identifier)

    assert_equal 403, validator.status
    assert_equal "Already Received Request - 403 Forbidden", validator.body
  end

  def test_returns_proper_messages_if_data_is_submitted_to_an_application_url_that_does_not_exist
    register_default_user

    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, "gobbiltygook")

    assert_equal 403, validator.status
    assert_equal "Application Not Registered - 403 Forbidden", validator.body
  end

  def test_inserts_sha_to_params
    validator = TrafficSpy::PayloadValidator.new
    assert_equal 40, validator.prep_sha(ruby_params_no_sha)["payload_sha"].length
  end

  def test_identifies_duplicate_data
    validator = TrafficSpy::PayloadValidator.new
    register_default_user

    refute validator.duplicate_data?(ruby_params_no_sha)

    ruby_params_sha = validator.prep_sha(ruby_params_no_sha)
    TrafficSpy::DbLoader.new(ruby_params_sha, default_identifier).load_databases

    assert validator.duplicate_data?(ruby_params_sha)

    ruby_params_sha2 = validator.prep_sha(ruby_params_no_sha.merge({"url"=>"AHHH"}))

    refute validator.duplicate_data?(ruby_params_sha2)
  end

  def test_identifies_missing_or_extra_attributes
    validator = TrafficSpy::PayloadValidator.new
    ruby_params_sha = validator.prep_sha(ruby_params_no_sha)
    refute validator.missing_or_extra_attribute?(ruby_params_sha)
    assert validator.missing_or_extra_attribute?(ruby_params_no_sha.tap {|x| x.delete("responded_in")})
  end
end
