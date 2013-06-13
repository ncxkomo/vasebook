require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
	should belong_to(:user)
	should belong_to(:friend)	

	test "that creating a friendship works without raising an exception" do 
		assert_nothing_raised do 
			UserFriendship.create(user: users(:rydawg), friend: users(:mikey))
		end
	end

	test "that creating a friendship on user id and friend id works" do 
		UserFriendship.create(user_id: users(:rydawg).id, friend_id: users(:mikey).id)
		assert users(:rydawg).friends.include?(users(:mikey))
	end

end
