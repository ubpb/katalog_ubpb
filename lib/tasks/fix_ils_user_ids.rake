desc "Fix ILS user IDs in database table 'users'."
task :fix_ils_user_ids => :environment do

  puts "Deleting users that have no watch lists and notes"
  User.left_joins(:watch_lists, :notes).where(watch_lists: {user_id: nil}, notes: {user_id: nil}).destroy_all

  puts "Fixing ilsuserid"
  User.find_each do |user|
    ils_user = IlsConnection.connection.get_user(user.ilsuserid)

    if ils_user
      new_ilsuserid = ils_user[:id]

      if new_ilsuserid == user.ilsuserid
        puts "SKIPED: user #{user.id} uses correct ilsuserid."
      else
        puts "FIXED: user #{user.id}: Old ILS ID '#{user.ilsuserid}' / New ILS ID '#{new_ilsuserid}'."
        user.update_attribute(:ilsuserid, new_ilsuserid)
      end
    else
      puts "ERROR: user with old ILS ID '#{user.ilsuserid}' does not exist in ILS. Deleting user."
      user.destroy
    end
  end

end
