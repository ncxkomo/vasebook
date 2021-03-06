require 'test_helper'

class UserTest < ActiveSupport::TestCase
	should have_many(:user_friendships)
	should have_many(:friends)
	should have_many(:pending_user_friendships)
	should have_many(:pending_friends)
	should have_many(:requested_user_friendships)
	should have_many(:requested_friends)
	should have_many(:blocked_user_friendships)
	should have_many(:blocked_friends)

	test "a user should enter a first name" do
		user = User.new
		assert !user.save
		assert !user.errors[:first_name].empty?
	end

	test "a user should enter a last name" do
		user = User.new
		assert !user.save
		assert !user.errors[:last_name].empty?
	end

	test "a user should enter a profile name" do
		user = User.new
		assert !user.save
		assert !user.errors[:profile_name].empty?
	end

	test "a user should have a unique profile name" do
		user = User.new
		user.profile_name = users(:rydawg).profile_name
		assert !user.save

		assert !user.errors[:profile_name].empty?
	end

	test "a user should have a profile name without spaces" do 
		user = User.new(first_name: "trick", last_name: "shorty")
		user.password = user.password_confirmation = 'afdsdsdsd'
		user.profile_name = "so many spaces"

		assert !user.save
		assert !user.errors[:profile_name].empty?


		assert user.errors[:profile_name].include?("Must be formatted correctly.") 
	end

	test "a user can have a properly formatted profile name" do 
		user = User.new(first_name: "trick", last_name: "shorty", email: 'test@test.com')
		user.password = user.password_confirmation = 'afdsdsdsd'
		
		user.profile_name = "theseARE__al92nospaCE"
		assert user.valid?
	end

	test "no error is raised when trying to access user's friend list" do
		assert_nothing_raised do
			users(:rydawg).friends
		end
	end

	test "that creating a friendship on user works" do 
		users(:rydawg).pending_friends << users(:mikey)
		users(:rydawg).pending_friends.reload
		assert users(:rydawg).pending_friends.include?(users(:mikey))
	end

	test "that calling to_param on a user returns the profile_name" do
		assert_equal "rydawg", users(:rydawg).to_param
	end

	context "#has_blocked?" do
		should "return true if a user has blocked another user" do
			assert users(:rydawg).has_blocked?(users(:blocked_friend))
		end

		should "return false if a user has not blocked another user" do
			assert !users(:rydawg).has_blocked?(users(:jimbo))
		end
	end

end
