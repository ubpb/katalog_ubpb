class RemovePadAlephPrefixFromWatchListEntries < ActiveRecord::Migration

  class WatchListEntry < ActiveRecord::Base
  end

  def up
    with_each_watch_list_entry_from_local_scope do |_watch_list_entry|
      if _watch_list_entry.recordid.start_with?("PAD_ALEPH")
        _watch_list_entry.recordid = _watch_list_entry.recordid.sub("PAD_ALEPH", "")
      end
    end
  end

  def down
    with_each_watch_list_entry_from_local_scope do |_watch_list_entry|
      if !_watch_list_entry.recordid.start_with?("PAD_ALEPH")
        _watch_list_entry.recordid = "PAD_ALEPH#{_watch_list_entry.recordid}"
      end
    end
  end

  private

  def with_each_watch_list_entry_from_local_scope
    return unless block_given?

    WatchListEntry.where(scopeid: "local").find_in_batches(batch_size: batch_size = 10000) do |_watch_list_entries_from_local_scope|
      puts "Processing #{batch_size} watch list entries"

      transaction do
        _watch_list_entries_from_local_scope.each do |_watch_list_entry_from_local_scope|
          yield _watch_list_entry_from_local_scope
          _watch_list_entry_from_local_scope.save
        end
      end
    end
  end
end
