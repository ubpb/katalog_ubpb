class AddPasswordResetTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token, :string, null: true, index: true, unique: true
    add_column :users, :password_reset_token_created_at, :timestamp, null: true
  end
end
