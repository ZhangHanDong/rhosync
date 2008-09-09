class AddObjectUpdateType < ActiveRecord::Migration
  def self.up
    add_column :object_values,:update_type,:string
  end

  def self.down
  end
end
