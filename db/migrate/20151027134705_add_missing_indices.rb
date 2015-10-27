class AddMissingIndices < ActiveRecord::Migration
  def up
    add_index :watch_lists, :user_id
    add_index :watch_list_entries, :watch_list_id
    add_index :watch_list_entries, :recordid
    add_index :watch_list_entries, :scopeid
  end
end
