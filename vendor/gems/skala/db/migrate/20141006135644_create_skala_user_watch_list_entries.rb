class CreateSkalaUserWatchListEntries < ActiveRecord::Migration
  def change
    create_table :skala_user_watch_list_entries do |t|
      t.string     :record_id
      t.string     :scope_id
      t.references :watch_list

      t.timestamps
    end

    add_index :skala_user_watch_list_entries, :watch_list_id
  end
end
