require "xml/libxml"

class ObjectValue < ActiveRecord::Base
  belongs_to :source

  def before_validate
    self.update_type="pending"
  end

end
