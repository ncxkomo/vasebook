require 'test_helper'

class AddAFriendTest < ActionDispatch::IntegrationTest

	def sign_in_as(user, password)
		post login_path, user: { email: user.email, password: password }
	end

	test "adding a friend works" do
		sign_in_as(users(:rydawg), "testing")

		get "/user_friendships/new?friend_id=#{users(:jimbo).profile_name}"
		assert_response :success

		assert_difference('UserFriendship.count', 1) do
      		post "/user_friendships", user_friendship: {friend_id: users(:jimbo).profile_name} 
      		assert_response :redirect
      		assert_equal "You are now friends with #{users(:jimbo).full_name}.", flash[:success]
    	end
	end

end
