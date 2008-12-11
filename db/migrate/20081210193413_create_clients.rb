class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :obj_key, :null => false
      t.string :client_id, :null => false
      t.string :update_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
