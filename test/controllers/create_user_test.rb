require_relative '../test_helper'

class CreateUserTest < ControllerTest

  def test_creates_genre_with_valid_attributes #happy path
    post '/sources', {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}

    assert_equal 200, last_response.status
    # assert_equal 1, Genre.count
    # assert_equal "Genre Created", last_response.body
  end

end
