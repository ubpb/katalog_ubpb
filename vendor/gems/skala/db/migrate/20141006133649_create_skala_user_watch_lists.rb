class CreateSkalaUserWatchLists < ActiveRecord::Migration
  def change
    create_table :skala_user_watch_lists do |t|
      t.text       :description
      t.string     :name
      t.boolean    :public, default: false
      t.references :user

      t.timestamps
    end

    add_index :skala_user_watch_lists, :user_id
  end
end
