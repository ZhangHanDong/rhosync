
class AddSourceColumns < ActiveRecord::Migration
  def self.up
    add_column :sources,:prolog,:text
    add_column :sources,:epilog,:text
    add_column :sources,:call,:text
    add_column :sources,:type,:string
  end
end