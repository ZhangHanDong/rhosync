class Client < ActiveRecord::Base
  has_many :object_values
  validates_presence_of :client_id, :message => 'is required'
end