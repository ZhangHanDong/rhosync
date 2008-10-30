require 'test_helper'

describe "ObjectValuesController", ActionController::TestCase do
  it "should get index" do
    get :index
    assert_response :success
    assigns(:object_values).should.not == nil
  end

  it "should get new" do
    get :new
    assert_response :success
  end

  it "should create object value" do
    assert_difference('ObjectValue.count') do
      post :create, :object_value => { }
    end

    assert_redirected_to object_value_path(assigns(:object_value))
  end


  it "should get edit" do
    get :edit, :id => object_values(:one).id
    assert_response :success
  end

  it "should update object value" do
    put :update, :id => object_values(:one).id, :object_value => { }
    assert_redirected_to object_value_path(assigns(:object_value))
  end

  it "should destroy object value" do
    assert_difference('ObjectValue.count', -1) do
      delete :destroy, :id => object_values(:one).id
    end

    assert_redirected_to object_values_path
  end
end
