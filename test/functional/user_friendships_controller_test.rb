require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
	context "#new" do
		context "when not logged in" do
			should "redirect to the login page" do
				get :new
				assert_response :redirect
    			assert_redirected_to new_user_session_path
    		end
    	end

    	context "when logged in" do
    		setup do
    			sign_in users(:rydawg)
    		end

    		should "get the new page" do
    			get :new
    			assert_response :success
    		end

    		should "should set a flash error if the friend_id param is missing" do
    			get :new, {}
    			assert_equal "Friend required.", flash[:error]
    		end

    		should "display the friend's name" do
    			get :new, friend_id: users(:mikey) 
    			assert_match /#{users(:mikey).full_name}/, response.body
    		end

    		should "assign a new user friendship instance" do
    			get :new, friend_id: users(:mikey)
    			assert assigns(:user_friendship)
    		end

            should "assign a new user friendship instance to correct friend" do
                get :new, friend_id: users(:mikey)
                assert_equal users(:mikey), assigns(:user_friendship).friend
            end

            should "assign a new user friendship instance to current user" do
                get :new, friend_id: users(:mikey)
                assert_equal users(:rydawg), assigns(:user_friendship).user
            end

            should "return a 404 status if no friend is found" do
                get :new, friend_id: 'invalid'
                assert_response :not_found
            end

            should "ask if you really want to friend the user" do
                get :new, friend_id: users(:mikey)
                assert_match /Do you really want to friend #{users(:mikey).full_name}?/, response.body
            end
    	end
	end
end
