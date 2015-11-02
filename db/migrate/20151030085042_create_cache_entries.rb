class CreateCacheEntries < ActiveRecord::Migration
  def change
    create_table :cache_entries do |t|
      t.string :key
      t.text   :value, limit: 4294967295

      t.timestamps
    end

    add_index :cache_entries, :key
  end
end
