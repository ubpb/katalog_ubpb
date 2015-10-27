class RemoveSearchesAndServerResponses < ActiveRecord::Migration
  def up
    drop_table :searches if table_exists? :searches
    drop_table :server_responses if table_exists? :server_responses
  end
end
