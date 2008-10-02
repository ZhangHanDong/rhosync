require 'test_helper'

class SourcesControllerTest < ActionController::TestCase

  def test_should_show_source
    get :show, :id => sources(:sugar).id
    assert_response :success
  end

  def test_should_show_null_when_waiting_for_refresh
    get :updateobjects,:id=>sources(:sugar).id,
      :attrvals=>[{"object"=>"1","attrib"=>"name","value"=>"rhomobile"}]

    get :show, :id => sources(:sugar).id, :last_update => Time.now.to_s
  end

  def test_should_createobjects
    get :createobjects,:id=>sources(:sugar).id,:attrvals=>[{"attrib"=>"name","value"=>"rhomobile"}]
    assert_response :success
  end

  def test_should_updateobjects
    get :updateobjects,:id=>sources(:sugar).id,     
      :attrvals=>[{"object"=>"1","attrib"=>"name","value"=>"rhomobile"}]
    assert_response :success
  end

  def test_should_deleteobjects
    get :deleteobjects, :id=>sources(:sugar),
      :attrvals=>[{"object"=>"1"}]
  end

  def test_should_refresh
    get :refresh,:id=>sources(:sugar).id
    assert_redirected_to source_path(assigns(:source))
  end

  def test_should_refresh_twice_with_same_count
    get :refresh,:id=>sources(:sugar).id
    # refresh is supposed to delete existing query records before reexecuting a query
    assert_no_difference 'ObjectValue.count' do
      get :refresh,:id=>sources(:sugar).id
    end
  end


  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_source
    assert_difference('Source.count') do
      post :create, :source => { }
    end

    assert_redirected_to source_path(assigns(:source))
  end

  def test_should_get_edit
    get :edit, :id => sources(:sugar).id
    assert_response :success
  end

  def test_should_update_source
    put :update, :id => sources(:sugar).id, :source => { }
    assert_redirected_to source_path(assigns(:source))
  end

  def test_should_destroy_source
    assert_difference('Source.count', -1) do
      delete :destroy, :id => sources(:sugar).id
    end

    assert_redirected_to sources_path
  end
end
