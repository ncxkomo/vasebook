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

    context "#create" do
        context "when not logged in" do
            should "redirect to the login page" do
                post :create
                assert_response :redirect
                assert_redirected_to login_path
            end
        end

        context "when logged in" do 
            setup do 
                sign_in users(:rydawg)
            end

            context "with no friend_id" do
                setup do 
                    post :create
                end

                should "set the flash error message" do
                    assert !flash[:error].empty?
                end

                should "redirect to the site root" do
                    assert_redirected_to root_path
                end
            end

        context "with friend_id"
            setup do
                post :create, user_friendship: { friend_id: users(:mikey) }
            end

            should "assign a friend instance object" do
                assert assigns(:friend)
                assert_equal assigns(:friend), users(:mikey)
            end

            should "assign a user friendship instance object" do
                assert assigns(:user_friendship)
                assert_equal assigns(:user_friendship).user, users(:rydawg)
                assert_equal assigns(:user_friendship).friend, users(:mikey)
            end

            should "create a friendship" do
                assert users(:rydawg).friends.include?(users(:mikey))
            end

            should "redirect to profile page of friend" do 
                assert_response :redirect
                assert_redirected_to profile_path(users(:mikey))
            end

            should "set the flash message" do
                assert flash[:success]
                assert_equal flash[:success], "You are now friends with #{users(:mikey).full_name}."
            end
        end
    end
end
