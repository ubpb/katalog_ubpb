class MigrateWatchLists < ActiveRecord::Migration
  def up
    remove_column :watch_lists, :master_watch_list_id
  end
end
