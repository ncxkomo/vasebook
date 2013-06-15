require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  setup do
    @status = statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statuses)
  end

  test "should display all users' posts when logged out" do
    users(:blocked_friend).statuses.create(content: 'Blocked status')
    users(:jimbo).statuses.create(content: 'Non-blocked status')
    get :index
    assert_match /Non\-blocked\ status/, response.body
    assert_match /Blocked\ status/, response.body
  end

  test "should not display blocked users' posts when logged in" do
    sign_in users(:rydawg)
    users(:blocked_friend).statuses.create(content: 'Blocked status')
    users(:jimbo).statuses.create(content: 'Non-blocked status')
    get :index
    assert_match /Non\-blocked\ status/, response.body
    assert_no_match /Blocked\ status/, response.body
  end

  test "should be logged in to get new status page" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should get to new status page when logged in" do
    sign_in users(:rydawg)
    get :new
    assert_response :success
  end

  test "should be logged in to create a status" do
    post :create, status: { content: "Yo." }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should be able to create a status when logged in" do
    sign_in users(:rydawg)
    assert_difference('Status.count') do
      post :create, status: { content: "Yo." }
    end
    assert_response :redirect
    assert_redirected_to status_path(assigns(:status))
  end

  test "should be able to create a status as current user when logged in" do
    sign_in users(:rydawg)
    assert_difference('Status.count') do
      post :create, status: { content: "Yo.", user_id: users(:jimbo).id }
    end
    assert_response :redirect
    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:rydawg).id
  end

  test "should show status" do
    get :show, id: @status
    assert_response :success
  end

  test "should be logged in to get to edit status page" do
    get :edit, id: @status
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should be able get to edit status page when logged in" do
    sign_in users(:rydawg)
    get :edit, id: @status
    assert_response :success
  end

  test "should be logged in to update status" do
    put :update, id: @status, status: { content: "Yo." }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should be able to update status when logged in" do
    sign_in users(:rydawg)
    put :update, id: @status, status: { content: "Yo." }
    assert_redirected_to status_path(assigns(:status))
  end

  test "should be able to update status for current user when logged in" do
    sign_in users(:rydawg)
    put :update, id: @status, status: { content: "Yo.", user_id: users(:jimbo).id }
    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:rydawg).id
  end

  test "should not update status when nothing has changed" do
    sign_in users(:rydawg)
    put :update, id: @status
    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:rydawg).id
  end


  test "should be logged in to destroy status" do
    delete :destroy, id: @status
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
  
  test "should be able to destroy status when logged in" do
    sign_in users(:rydawg)
    assert_difference('Status.count', -1) do
      delete :destroy, id: @status
    end
    assert_redirected_to statuses_path
  end
end
