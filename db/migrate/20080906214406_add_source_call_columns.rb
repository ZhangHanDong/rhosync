class AddSourceCallColumns < ActiveRecord::Migration
  def self.up
    add_column :sources,:createcall,:text
    add_column :sources,:updatecall,:text
    add_column :sources,:deletecall,:text
  end

  def self.down
  end
end
