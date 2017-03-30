class FixUsersId < ActiveRecord::Migration[5.0]
  def up
    # Lets save the current "wrong" id column
    rename_column :users, :ilsuserid, :ilsusername

    # Add the new "correct" id column
    add_column :users, :ilsuserid, :string
    add_index  :users, :ilsuserid, unique: true

    # Delete all users that don't have any note or watch list.
    # They will be recreated correcty the next time they log in.
    execute <<-SQL
      delete from users
             where not exists (select id from watch_lists where watch_lists.user_id = users.id)
             and   not exists (select id from notes where notes.user_id = users.id)
    SQL

    # Delete NULL users.
    execute <<-SQL
      delete from users where ilsusername is NULL
    SQL

    # The remaining users must be migrated by fetching the correct ilsuserid
    # for the existing ilsusername
    User.all.each do |user|
      aleph_adapter = KatalogUbpb.config.ils_adapter.instance
      result = aleph_adapter.get_user(user.ilsusername)

      if result.present? && result.id.present?
        user.update_attributes(ilsuserid: result.id)
        puts "Ok: Migrated user '#{user.ilsusername}' to '#{result.id}'"
      else
        user.destroy
        puts "Error: No result found for user '#{user.ilsusername}'. Deleted local record."
      end

      # De-stress Aleph
      sleep(0.1)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
