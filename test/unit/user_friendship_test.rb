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

	context "#mutual_friendship" do
		setup do
			UserFriendship.request users(:rydawg), users(:mikey)
			@friendship1 = users(:rydawg).user_friendships.where(friend_id: users(:mikey).id).first
			@friendship2 = users(:mikey).user_friendships.where(friend_id: users(:rydawg).id).first
		end

		should "correctly find mutual friendship" do
			assert_equal @friendship2, @friendship1.mutual_friendship 
		end
	end	

	context "#accept_mutual_friendship!" do
		setup do
			UserFriendship.request users(:rydawg), users(:mikey)
		end

		should "accept mutual friendship" do
			friendship1 = users(:rydawg).user_friendships.where(friend_id: users(:mikey).id).first
			friendship2 = users(:mikey).user_friendships.where(friend_id: users(:rydawg).id).first

			friendship1.accept_mutual_friendship!
			friendship2.reload
			assert_equal 'accepted', friendship2.state 
		end
	end

	context "#accept!" do
		setup do
			@user_friendship = UserFriendship.request(users(:rydawg), users(:mikey))
		end

		should "set the state to accepted" do
			@user_friendship.accept!
			assert_equal 'accepted', @user_friendship.state 
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

		should "accept the mutual friendship" do 
			@user_friendship.accept!
			assert_equal 'accepted', @user_friendship.mutual_friendship.state 
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

	context "#delete_mutual_friendship!" do
		setup do
			UserFriendship.request users(:rydawg), users(:mikey)
			@friendship1 = users(:rydawg).user_friendships.where(friend_id: users(:mikey).id).first
			@friendship2 = users(:mikey).user_friendships.where(friend_id: users(:rydawg).id).first  
		end

		should "delete the mutual friendship" do
			assert_equal @friendship2, @friendship1.mutual_friendship
			@friendship1.delete_mutual_friendship!
			assert !UserFriendship.exists?(@friendship2.id) 
		end
	end

	context "on destroy" do
		setup do
			UserFriendship.request users(:rydawg), users(:jimbo)
			@friendship1 = users(:rydawg).user_friendships.where(friend_id: users(:jimbo).id).first
			@friendship2 = users(:jimbo).user_friendships.where(friend_id: users(:rydawg).id).first  
		end

		should "destroy the mutual friendship" do
			@friendship1.destroy
			assert !UserFriendship.exists?(@friendship2.id) 
		end
	end

	context "#block!" do #block! is added by state machine once add state for it
		setup do
			@user_friendship = UserFriendship.request users(:rydawg), users(:mikey)
		end
		
		should "set the state to blocked" do
			@user_friendship.block!
			assert_equal 'blocked', @user_friendship.state
			assert_equal 'blocked', @user_friendship.mutual_friendship.state
		end

		should "not allow new requests once blocked" do
			@user_friendship.block!
			uf = UserFriendship.request users(:rydawg), users(:mikey)
			assert !uf.save
		end
	end
end
