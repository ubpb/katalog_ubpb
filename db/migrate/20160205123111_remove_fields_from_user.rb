class RemoveFieldsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :number_of_hold_requests
    remove_column :users, :number_of_loans
    remove_column :users, :cash_balance
  end
end
