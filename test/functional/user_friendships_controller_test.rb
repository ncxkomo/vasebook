require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
	context "#index" do
		context "when not logged in" do
			should "redirect to the login page" do
				get :index
				assert_response :redirect
				assert_redirected_to new_user_session_path
			end
		end

		context "when logged in" do
			setup do
				@friendship1 = create(:pending_user_friendship, user: users(:rydawg), friend: create(:user, first_name: 'Pending', last_name: 'Friend'))
				@friendship2 = create(:accepted_user_friendship, user: users(:rydawg), friend: create(:user, first_name: 'Accepted', last_name: 'Friend'))
				@friendship3 = create(:requested_user_friendship, user: users(:rydawg), friend: create(:user, first_name: 'Requested', last_name: 'Friend'))
				@friendship4 = user_friendships(:blocked_by_rydawg)
				
				sign_in users(:rydawg)
				get :index
			end

			should "get the index page without error" do
				assert_response :success                
			end

			should "assign user_friendship instance variable" do
				assert assigns(:user_friendships)
			end

			should "display friends' names" do
				assert_match /Accepted/, response.body
				assert_match /Pending/, response.body
			end

			should "display pending information on a pending friendship" do
				assert_select "#user_friendship_#{@friendship1.id}" do 
					assert_select "em", "Friendship is pending."
				end
			end

			should "display date information on an accepted friendship" do 
				assert_select "#user_friendship_#{@friendship2.id}" do 
					assert_select "em", "Friendship started at #{@friendship2.updated_at}."
				end
			end
			
			context "blocked users" do
				setup do
					get :index, list: 'blocked'
				end

				should "get the index without error" do
					assert_response :success
				end

				should "not display pending or active friends' names" do
					assert_no_match /Pending\ Friend/, response.body # need to escape space
					assert_no_match /Active\ Friend/, response.body 
				end

				should "display blocked friend names" do
					assert_match /Blocked\ Friend/, response.body
				end
			end
			
			context "pending users" do
				setup do
					get :index, list: 'pending'
				end

				should "get the index without error" do
					assert_response :success
				end

				should "not display blocked or active friends' names" do
					assert_no_match /Blocked\ Friend/, response.body # need to escape space
					assert_no_match /Active\ Friend/, response.body 
				end

				should "display pending friend names" do
					assert_match /Pending\ Friend/, response.body
				end
			end

			context "requested users" do
				setup do
					get :index, list: 'requested'
				end

				should "get the index without error" do
					assert_response :success
				end

				should "not display blocked or active friends' names" do
					assert_no_match /Blocked\ Friend/, response.body # need to escape space
					assert_no_match /Active\ Friend/, response.body 
				end

				should "display requested friend names" do
					assert_match /Requested/, response.body
				end
			end

			context "accepted friendships" do
				setup do
					get :index, list: 'accepted'
				end

				should "get the index without error" do
					assert_response :success
				end

				should "not display blocked or requested friends' names" do
					assert_no_match /Blocked\ Friend/, response.body # need to escape space
					assert_no_match /Requested\ Friend/, response.body 
				end

				should "display accepted friend names" do
					assert_match /Accepted\ Friend/, response.body
				end
			end
		end
	end

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

		context "successfully" do
			should "create two user friendship objects" do
				assert_difference('UserFriendship.count', 2) do
					post :create, user_friendship: { friend_id: users(:mikey) }	
				end
			end 
		end

		context "with friend_id"
			setup do
				post :create, user_friendship: { friend_id: users(:mikey) }
			end

			should "assign a friend instance object" do
				assert assigns(:friend)
				assert_equal users(:mikey), assigns(:friend) 
			end

			should "assign a user friendship instance object" do
				assert assigns(:user_friendship)
				assert_equal users(:rydawg), assigns(:user_friendship).user
				assert_equal users(:mikey), assigns(:user_friendship).friend 
			end

			should "create a friendship" do
				assert users(:rydawg).pending_friends.include?(users(:mikey))
			end

			should "redirect to profile page of friend" do 
				assert_response :redirect
				assert_redirected_to profile_path(users(:mikey))
			end

			should "set the flash message" do
				assert flash[:success]
				assert_equal "Friend request sent.", flash[:success] 
			end
		end
	end

	context "#accept!" do
		context "when not logged in" do
			should "redirect to the login page" do
				put :accept, id: 1
				assert_response :redirect
				assert_redirected_to login_path
			end
		end

		context "when logged in" do
			setup do
				@friend = create(:user)
				@user_friendship = create(:pending_user_friendship, user: users(:rydawg), friend: @friend)
	    		create(:pending_user_friendship, friend: users(:rydawg), user: @friend)
				sign_in users(:rydawg)
				put :accept, id: @user_friendship
				@user_friendship.reload
			end

			should "assign user_friendship instance" do
				assert assigns(:user_friendship)
				assert_equal @user_friendship, assigns(:user_friendship)
			end

			should "update the state to accepted" do
				assert_equal 'accepted', @user_friendship.state
			end

			should "have a flash success message" do
			  assert_equal "You are now friends with #{@user_friendship.friend.first_name}", flash[:success]
			end
		end
	end

	context "#edit" do 
		context "when not logged in" do
			should "redirect to login page" do
				get :edit, id: 1
				assert_response :redirect
				assert_redirected_to login_path        
			end
		end

		context "when logged in" do 
			setup do 
				@friend = create(:user)
				@user_friendship = create(:pending_user_friendship, user: users(:rydawg), friend: @friend)       		
				sign_in users(:rydawg)
				get :edit, id: @user_friendship.friend.profile_name
			end

			should "get edit and return success" do
				assert_response :success
			end

			should "assign a user_friendship instance" do
				assert assigns(:user_friendship)
				assert_equal @user_friendship, assigns(:user_friendship)
			end

			should "assign to friend" do
				assert assigns(:friend)
			end
		end
	end

	context "#destroy" do 
		context "when not logged in" do
			should "redirect to the login page" do
				delete :destroy, id: 1 
				assert_response :redirect
				assert_redirected_to login_path
			end
		end

		context "when logged in" do
			setup do
				@friend = create(:user)
				@user_friendship = create(:accepted_user_friendship, friend: @friend, user: users(:rydawg)) 
				create(:accepted_user_friendship, friend: users(:rydawg), user: @friend)

				sign_in users(:rydawg)
				@user_friendship.reload
			end

			should "delete user friendships" do
				assert_difference 'UserFriendship.count', -2 do
					delete :destroy, id: @user_friendship
				end
			end
	
			should "set the flash" do
				delete :destroy, id: @user_friendship
				assert_equal 'Friendship destroyed', flash[:success]
			end
		end
	end

	context "#block!" do
		context "when not logged in" do
			should 'redirect to the login page' do
				put :block, id: 1
				assert_response :redirect
				assert_redirected_to login_path
			end
		end

		context "when logged in" do 
			setup do
				@user_friendship = create(:pending_user_friendship, user: users(:rydawg))
				sign_in users(:rydawg)
				put :block, id: @user_friendship
				@user_friendship.reload # because state has changed
			end

			should "assign a user friendship object" do
				assert assigns(:user_friendship)
				assert_equal @user_friendship, assigns(:user_friendship)
			end

			should "update the user friendship state to blocked" do
				assert_equal 'blocked', @user_friendship.state
			end
		end
	end
end