require_relative '../test_helper'

class UserValidatorTest < ModelTest
  def test_class_exists
    assert TrafficSpy::UserValidator
  end

  def test_validate_method_returns_proper_messages_for_good_params
    params = {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    validator = TrafficSpy::UserValidator.new
    validator.validate(params)

    assert_equal 200, validator.status
    assert_equal "Success - 200 OK: User registered! {'identifier':'jumpstartlab'}", validator.body
  end

  def test_validate_method_returns_proper_messages_for_missing_params
    params = {"rootUrl"=>"http://jumpstartlab.com"}
    validator = TrafficSpy::UserValidator.new
    validator.validate(params)

    assert_equal 400, validator.status
    assert_equal "Missing Parameters - 400 Bad Request", validator.body
  end

  def test_validate_method_returns_proper_messages_when_user_already_exists
    TrafficSpy::User.create({"identifier"=>"jumpstartlab", "root_url"=>"http://jumpstartlab.com"})
    params = {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    validator = TrafficSpy::UserValidator.new
    validator.validate(params)

    assert_equal 403, validator.status
    assert_equal "Identifier Already Exists - 403 Forbidden", validator.body
  end
end
