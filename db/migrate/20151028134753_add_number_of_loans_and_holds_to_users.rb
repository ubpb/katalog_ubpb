class AddNumberOfLoansAndHoldsToUsers < ActiveRecord::Migration
  def up
     add_column :users, :number_of_hold_requests, :integer
     add_column :users, :number_of_loans,         :integer
  end
end
