class AddSourceRefreshtime < ActiveRecord::Migration
  def self.up
    add_column :sources,:refreshtime,:datetime
  end

  def self.down
  end
end
