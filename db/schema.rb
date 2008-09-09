# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080906214406) do

  create_table "object_values", :force => true do |t|
    t.integer  "source_id",   :limit => 11
    t.string   "attribute"
    t.string   "object"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "update_type"
  end

  create_table "sources", :force => true do |t|
    t.string   "server"
    t.string   "url"
    t.string   "login"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "prolog"
    t.text     "epilog"
    t.text     "call"
    t.text     "sync"
    t.string   "type"
    t.text     "createcall"
    t.text     "updatecall"
    t.text     "deletecall"
  end

end
