class MigrateWatchListEntries < ActiveRecord::Migration
  def up
    rename_column :watch_list_entries, :resourceid, :recordid
    remove_column :watch_list_entries, :resourcetype
    remove_column :watch_list_entries, :label
    remove_column :watch_list_entries, :note
  end
end
