require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Client do
  before(:each) do
    @valid_attributes = {
      :obj_key => "value for obj_key",
      :client_id => "value for client_id",
      :update_type => "value for update_type"
    }
  end

  it "should create a new instance given valid attributes" do
    Client.create!(@valid_attributes)
  end
  
  it "should throw error on invalid attributes" do
    @client = Client.new
    puts "client errors: #{@client.inspect}"
    @client.errors.on(:client_id).should_equal "is required"
    @client.client_id = 'something new'
    @client.should_be_valid
  end
end
