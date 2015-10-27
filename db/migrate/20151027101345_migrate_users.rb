class MigrateUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base
    has_many :notes, dependent: :destroy
    has_many :watch_lists, dependent: :destroy
  end

  class Note < ActiveRecord::Base
    belongs_to :user
  end

  class WatchList < ActiveRecord::Base
    belongs_to :user
  end


  def up
    result = ActiveRecord::Base.connection.exec_query(
      "SELECT users.ilsuserid FROM users INNER JOIN
      (SELECT ilsuserid FROM users GROUP BY ilsuserid HAVING count(id) > 1) dup
      ON users.ilsuserid = dup.ilsuserid"
    )
    ilsuserids = result.rows.flatten

    ActiveRecord::Base.transaction do
      ilsuserids.each do |ilsuserid|
        if users_with_same_ilsuserid = User.where(ilsuserid: ilsuserid).order("id ASC")
          most_current_user = users_with_same_ilsuserid.last
          former_users      = users_with_same_ilsuserid[0..-2]

          former_users.each do |former_user|
            former_user.destroy
          end
        end
      end
    end

    rename_column :users, :firstname, :first_name
    rename_column :users, :lastname, :last_name
    rename_column :users, :email, :email_address
    remove_column :users, :ilsid
    remove_column :users, :role

    add_index :users, :ilsuserid, unique: true
  end
end
