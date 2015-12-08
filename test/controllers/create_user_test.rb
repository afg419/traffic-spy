require_relative '../test_helper'

class CreateUserTest < ControllerTest

  def test_creates_user_with_valid_attributes #happy path
    initial_count = User.count
    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    final_count = User.count

    assert_equal 200, last_response.status
    assert_equal 1, final_count - initial_count
    assert_equal "User registered!", last_response.body
  end

end
