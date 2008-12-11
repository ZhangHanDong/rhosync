require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/clients/new.html.erb" do
  include ClientsHelper
  
  before(:each) do
    assigns[:client] = stub_model(Client,
      :new_record? => true,
      :obj_key => "value for obj_key",
      :update_type => "value for update_type"
    )
  end

  it "should render new form" do
    render "/clients/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", clients_path) do
      with_tag("input#client_obj_key[name=?]", "client[obj_key]")
      with_tag("input#client_update_type[name=?]", "client[update_type]")
    end
  end
end


