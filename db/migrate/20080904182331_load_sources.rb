require 'active_record/fixtures'

class LoadSources < ActiveRecord::Migration
  def self.up
    Fixtures.create_fixtures(File.dirname(__FILE__),"sources")
  end

  def self.down
    Source.delete_all
  end

end
