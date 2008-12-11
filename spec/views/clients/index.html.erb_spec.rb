require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/clients/index.html.erb" do
  include ClientsHelper
  
  before(:each) do
    assigns[:clients] = [
      stub_model(Client,
        :obj_key => "value for obj_key",
        :update_type => "value for update_type"
      ),
      stub_model(Client,
        :obj_key => "value for obj_key",
        :update_type => "value for update_type"
      )
    ]
  end

  it "should render list of clients" do
    render "/clients/index.html.erb"
    response.should have_tag("tr>td", "value for obj_key", 2)
    response.should have_tag("tr>td", "value for update_type", 2)
  end
end

