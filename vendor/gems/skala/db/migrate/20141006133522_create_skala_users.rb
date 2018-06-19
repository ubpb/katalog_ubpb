class CreateSkalaUsers < ActiveRecord::Migration
  def change
    create_table :skala_users do |t|
      t.string :api_key
      t.string :username

      t.timestamps
    end

    add_index :skala_users, :api_key, unique: true
    add_index :skala_users, :username, unique: true
  end
end
