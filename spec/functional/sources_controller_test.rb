require 'test_helper'

describe "SourcesController", ActionController::TestCase do

  it "should create and delete objects and refresh" do
    result=get :createobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>"temp1","attrib"=>"name","value"=>"rhomobile"}]
    p "Created new object with ID: " +result.id.to_s
    get :deleteobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>result.id}]
    p "Result of delete: "+result.inspect.to_s
    get :refresh, :id=>sources(:sugar).id
    assert_redirected_to source_path(assigns(:source))
  end

  it "should create and update objects and refresh" do
    result=get :createobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>"temp1","attrib"=>"name","value"=>"xmobile"}]
    p "Created new object with ID: " +result.id.to_s
    get :updateobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>result.id,"attrib"=>"name","value"=>"rhomobile"}]
    p "Result of update: "+result.inspect.to_s
    get :refresh, :id=>sources(:sugar).id
    assert_redirected_to source_path(assigns(:source))
  end

  it "should createobjects and refresh" do
    get :createobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>"temp1","attrib"=>"name","value"=>"rhomobile"}]
    get :refresh, :id=>sources(:sugar).id
    assert_redirected_to source_path(assigns(:source))
  end

  it "should show source" do
    get :show, :id => sources(:sugar).id
    assert_response :success
  end

  it "should retrieve attributes" do
    get :attributes, :id => sources(:sugar).id
    assert_response :success
  end

  it "should show null when waiting for refresh" do
    get :updateobjects,:id=>sources(:sugar).id,
      :attrvals=>[{"object"=>"1","attrib"=>"name","value"=>"rhomobile"}]

    get :show, :id => sources(:sugar).id, :last_update => Time.now.to_s
  end

  it "should createobjects" do
    get :createobjects,:id=>sources(:sugar).id,:attrvals=>[{"object"=>"temp1","attrib"=>"name","value"=>"rhomobile"}]
    assert_redirected_to source_path(assigns(:source))
  end

  it "should updateobjects" do
    get :updateobjects,:id=>sources(:sugar).id,     
      :attrvals=>[{"object"=>"1","attrib"=>"name","value"=>"rhomobile"}]
    assert_redirected_to source_path(assigns(:source))
  end

  it "should deleteobjects" do
    get :deleteobjects, :id=>sources(:sugar),
      :attrvals=>[{"object"=>"1"}]
  end

  it "should refresh" do
    get :refresh,:id=>sources(:sugar).id
    assert_redirected_to source_path(assigns(:source))
  end

  it "should refresh twice with same count" do
    get :refresh,:id=>sources(:sugar).id
    # refresh is supposed to delete existing query records before reexecuting a query
    assert_no_difference 'ObjectValue.count' do
      get :refresh,:id=>sources(:sugar).id
    end
  end


  it "should get index" do
    get :index
    assert_response :success
    assigns(:sources).should.not == nil
  end

  it "should get new" do
    get :new
    assert_response :success
  end

  it "should create source" do
    assert_difference('Source.count') do
      post :create, :source => { }
    end

    assert_redirected_to source_path(assigns(:source))
  end

  it "should get edit" do
    get :edit, :id => sources(:sugar).id
    assert_response :success
  end

  it "should update source" do
    put :update, :id => sources(:sugar).id, :source => { }
    assert_redirected_to source_path(assigns(:source))
  end

  it "should destroy source" do
    assert_difference('Source.count', -1) do
      delete :destroy, :id => sources(:sugar).id
    end

    assert_redirected_to sources_path
  end

end
