class AddObjKeyToObjectValues < ActiveRecord::Migration
  def self.up
    add_column :object_values, :obj_key, :string
  end

  def self.down
    remove_column :object_values, :obj_key
  end
end
