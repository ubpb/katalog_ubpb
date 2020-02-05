desc "Cleanup orphaned records"
task :cleanup_orphaned_records => :environment do
  WatchListEntry.left_outer_joins(:watch_list).where(watch_lists: {id: nil}).delete_all
  WatchList.left_outer_joins(:user).where(users: {id: nil}).delete_all
  Note.left_outer_joins(:user).where(users: {id: nil}).delete_all
end
