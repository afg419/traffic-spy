require_relative '../test_helper'

class CreateUserTest < ControllerTest

  def test_creates_TrafficSpy::user_with_valid_attributes #happy path
    initial_count = TrafficSpy::User.count
    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    final_count = TrafficSpy::User.count

    assert_equal 200, last_response.status
    assert_equal 1, (final_count - initial_count)
    assert_equal "Success - 200 OK: TrafficSpy::User registered! {'identifier':'jumpstartlab'}", last_response.body
  end

  def test_400_is_returned_if_name_param_is_missing
    initial_count = TrafficSpy::User.count
    post '/sources', {"identifier"=>"", "rootUrl"=>"http://jumpstartlab.com"}
    final_count = TrafficSpy::User.count

    assert_equal 400, last_response.status
    assert_equal 0, (final_count - initial_count)
    assert_equal "Missing Parameters - 400 Bad Request", last_response.body
  end

  def test_400_is_returned_if_rootUrl_param_is_missing
    initial_count = TrafficSpy::User.count
    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>""}
    final_count = TrafficSpy::User.count

    assert_equal 400, last_response.status
    assert_equal 0, (final_count - initial_count)
    assert_equal "Missing Parameters - 400 Bad Request", last_response.body
  end

  def test_403_is_returned_if_TrafficSpy::user_already_exists
    initial_count = TrafficSpy::User.count
    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    final_count = TrafficSpy::User.count
    assert_equal 1, (final_count - initial_count)

    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    final_count = TrafficSpy::User.count
    assert_equal 1, (final_count - initial_count)

    assert_equal 403, last_response.status
    assert_equal "Identifier Already Exists - 403 Forbidden", last_response.body
  end

end
