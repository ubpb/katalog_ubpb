class AddScopeToWatchListEntries < ActiveRecord::Migration

  class WatchListEntry < ActiveRecord::Base ; end

  def up
    add_column :watch_list_entries, :scopeid, :string, null: false
    WatchListEntry.reset_column_information

    WatchListEntry.find_each.with_index do |entry, index|
      puts "Processed #{index} records" if index % 1000 == 0

      scopeid = scopeid_from_recordid(entry.recordid)
      entry.update_attribute(:scopeid, scopeid)
    end
  end

  private

  def scopeid_from_recordid(recordid)
    if recordid.upcase.start_with?("PAD_ALEPH")
      "local"
    else
      "primo_central"
    end
  end
end
