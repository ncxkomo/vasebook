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
		assert users(:rydawg).pending_friends.include?(users(:mikey))
	end

	context "a new user_friendship instance" do
		setup do
			@user_friendship = UserFriendship.new(user: users(:rydawg), friend: users(:mikey))
		end

		should "have pending state" do
			assert_equal @user_friendship.state, 'pending'
		end
	end

	context "#send_request_email" do
		setup do
			@user_friendship = UserFriendship.create(user: users(:rydawg), friend: users(:mikey))
		end

		should "send a request email" do
			assert_difference('ActionMailer::Base.deliveries.size', 1) do
				@user_friendship.send_request_email
			end
		end
	end

	context "#accept!" do
		setup do
			@user_friendship = UserFriendship.create(user: users(:rydawg), friend: users(:mikey))
		end

		should "set the state to accepted" do
			@user_friendship.accept!
			assert_equal @user_friendship.state, 'accepted'
		end

		should "send an acceptance email" do
			assert_difference('ActionMailer::Base.deliveries.size', 1) do
				@user_friendship.accept!
			end
		end 

		should "include new friend in user's list of friends" do
			@user_friendship.accept!
			users(:rydawg).friends.reload
			assert users(:rydawg).friends.include?(users(:mikey))
		end
	end

	context ".request" do
		should "create two user friendships" do
			assert_difference('UserFriendship.count', 2) do
				UserFriendship.request(users(:rydawg), users(:mikey))
			end
		end

		should "send a friend request email" do
			assert_difference('ActionMailer::Base.deliveries.size', 1) do
				UserFriendship.request(users(:rydawg), users(:mikey))
			end
		end

	end
end
