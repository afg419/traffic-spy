require_relative '../test_helper'

class PayloadValidatorTest < ModelTest

  def ruby_params
    {"url"=>"blog",
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

  def load_user_info
    TrafficSpy::User.create("identifier"=>"jumpstartlab", "root_url"=>"http://jumpstartlab.com")
  end

  def test_class_exists
    assert TrafficSpy::PayloadValidator
  end

  def test_validate_method_returns_proper_messages_for_good_params
    load_user_info
    identifier = "jumpstartlab"
    validator = TrafficSpy::PayloadValidator.new
    validator.validate(ruby_params, identifier)

    assert_equal 200, validator.status
    assert_equal "Success - 200 OK", validator.body
  end

  def test_validate_method_returns_proper_messages_for_missing_params
    load_user_info
    identifier = "jumpstartlab"

    key_to_delete = ruby_params.keys.sample
    incomplete_params = ruby_params
    incomplete_params.delete(key_to_delete)
    validator = TrafficSpy::PayloadValidator.new
    validator.validate(incomplete_params, identifier)

    assert_equal 400, validator.status
    assert_equal "Missing Payload - 400 Bad Request", validator.body
  end

  def test_validate_method_returns_proper_messages_for_duplicate_payload
    load_user_info
    identifier = "jumpstartlab"

    TrafficSpy::Payload.create(ruby_params)

    validator = TrafficSpy::PayloadValidator.new
    validator.validate(ruby_params, identifier)

    assert_equal 403, validator.status
    assert_equal "Already Received Request - 403 Forbidden", validator.body
  end

  def test_validate_method_returns_proper_messages_if_data_is_submitted_to_an_application_url_that_does_not_exist
    load_user_info
    identifier = "gobbiltygook"

    validator = TrafficSpy::PayloadValidator.new
    validator.validate(ruby_params, identifier)

    assert_equal 403, validator.status
    assert_equal "Application Not Registered - 403 Forbidden", validator.body
  end
end
