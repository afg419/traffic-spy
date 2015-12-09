require_relative '../test_helper'

class UserValidatorTest < Minitest::Test
  def test_class_exists
    assert TrafficSpy::UserValidator
  end

  def test_validate_method
    params = {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    validated = TrafficSpy::UserValidator.new
    validated.validate(params)

    assert_equal 200, validated.status
  end

  def test_it_returns_status_400
      params = params = {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
      validated = TrafficSpy::UserValidator.new
      validated.validate(params)

      assert_equal 400, validated.status
  end
end
