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
    put :update, id: @status, status: { content: @status.content }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should be able to update status when logged in" do
    sign_in users(:rydawg)
    put :update, id: @status, status: { content: @status.content }
    assert_redirected_to status_path(assigns(:status))
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
