class MigrateApiTokens < ActiveRecord::Migration

  class User < ActiveRecord::Base
    has_many :api_keys
  end

  class ApiKey < ActiveRecord::Base
    belongs_to :user
  end

  def up
    add_column :users, :api_key, :string
    add_index :users, :api_key, unique: true

    # http://stackoverflow.com/questions/972562/rails-wont-let-me-change-records-during-migration
    User.reset_column_information

    ActiveRecord::Base.transaction do
      User.find_each.with_index do |user, index|
        puts "Processed #{index} users" if index % 1000 == 0
        key = user.api_keys.first
        if key && key.access_token.present?
          user.update_attribute(:api_key, key.access_token)
        end
      end
    end

    drop_table :api_keys
  end
end
