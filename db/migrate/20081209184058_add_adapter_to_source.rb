class AddAdapterToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :adapter, :string
  end

  def self.down
    remove_column :sources, :adapter
  end
end
