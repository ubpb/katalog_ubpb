class AddForeignKeyConstraints < ActiveRecord::Migration[6.0]

  def up
    add_foreign_key :watch_list_entries, :watch_lists, on_delete: :cascade
    add_foreign_key :watch_lists, :users, on_delete: :cascade
    add_foreign_key :notes, :users, on_delete: :cascade
  end

end
