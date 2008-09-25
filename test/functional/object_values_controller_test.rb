require 'test_helper'

class ObjectValuesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:object_values)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_object_value
    assert_difference('ObjectValue.count') do
      post :create, :object_value => { }
    end

    assert_redirected_to object_value_path(assigns(:object_value))
  end


  def test_should_get_edit
    get :edit, :id => object_values(:one).id
    assert_response :success
  end

  def test_should_update_object_value
    put :update, :id => object_values(:one).id, :object_value => { }
    assert_redirected_to object_value_path(assigns(:object_value))
  end

  def test_should_destroy_object_value
    assert_difference('ObjectValue.count', -1) do
      delete :destroy, :id => object_values(:one).id
    end

    assert_redirected_to object_values_path
  end
end
