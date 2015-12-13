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

  def register_user(j = nil)
    TrafficSpy::User.create("identifier"=>"jumpstartlab#{j}", "root_url"=>"http://jumpstartlab.com")
  end

  def test_class_exists
    assert TrafficSpy::PayloadValidator
  end

  def test_returns_proper_messages_for_good_params
    register_user
    identifier = "jumpstartlab"
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    assert_equal 200, validator.status
    assert_equal "Success - 200 OK", validator.body
  end

  def test_assigns_payload_to_correct_user
    register_user
    identifier = "jumpstartlab"
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    assert_equal 200, validator.status
    assert_equal 1, TrafficSpy::Payload.all.first.user_id
  end

  def test_assigns_url_to_correct_user
    register_user
    identifier = "jumpstartlab"
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    assert_equal 200, validator.status
    assert_equal 1, TrafficSpy::Payload.all.first.url_id
  end

  def test_assigns_object_to_correct_user_multiple_users
    register_user
    register_user(1)

    identifier = "jumpstartlab"
    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    identifier = "jumpstartlab1"
    validator.insert_or_error_status(ruby_params_no_sha(1), identifier)

    identifier = "jumpstartlab1"
    validator.insert_or_error_status(ruby_params_no_sha(2), identifier)

    identifier = "jumpstartlab"
    validator.insert_or_error_status(ruby_params_no_sha(3), identifier)

    first_urls = TrafficSpy::User.find_by(identifier:"jumpstartlab").payloads.map{|x| x.url.url}
    second_urls = TrafficSpy::User.find_by(identifier:"jumpstartlab1").payloads.map{|x| x.url.url}

    assert_equal ["blog","blog3"], first_urls
    assert_equal ["blog1", "blog2"], second_urls
  end


  def test_returns_proper_messages_for_missing_params
    register_user
    identifier = "jumpstartlab"

    key_to_delete = ruby_params_no_sha.keys.sample
    incomplete_params = ruby_params_no_sha
    incomplete_params.delete(key_to_delete)
    validator = TrafficSpy::PayloadValidator.new

    validator.insert_or_error_status(incomplete_params, identifier)

    assert_equal 400, validator.status
    assert_equal "Missing Payload - 400 Bad Request", validator.body
  end

  def test_returns_proper_messages_for_duplicate_payload
    register_user
    identifier = "jumpstartlab"

    validator = TrafficSpy::PayloadValidator.new
    TrafficSpy::DbLoader.new(validator.prep_sha(ruby_params_no_sha),identifier).load_databases
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    assert_equal 403, validator.status
    assert_equal "Already Received Request - 403 Forbidden", validator.body
  end

  def test_returns_proper_messages_if_data_is_submitted_to_an_application_url_that_does_not_exist
    register_user
    identifier = "gobbiltygook"

    validator = TrafficSpy::PayloadValidator.new
    validator.insert_or_error_status(ruby_params_no_sha, identifier)

    assert_equal 403, validator.status
    assert_equal "Application Not Registered - 403 Forbidden", validator.body
  end

  def test_inserts_sha_to_params
    validator = TrafficSpy::PayloadValidator.new
    assert_equal 40, validator.prep_sha(ruby_params_no_sha)["payload_sha"].length
  end

  def test_identifies_duplicate_data
    validator = TrafficSpy::PayloadValidator.new
    register_user
    identifier = "jumpstartlab"

    refute validator.duplicate_data?(ruby_params_no_sha)

    ruby_params_sha = validator.prep_sha(ruby_params_no_sha)
    TrafficSpy::DbLoader.new(ruby_params_sha,identifier).load_databases

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
