class ChangeNamingOfIdsForWatchListEntries < ActiveRecord::Migration
  def change
    change_table :watch_list_entries do |t|
      t.rename :recordid, :record_id
      t.rename :scopeid, :scope_id
    end
  end
end
