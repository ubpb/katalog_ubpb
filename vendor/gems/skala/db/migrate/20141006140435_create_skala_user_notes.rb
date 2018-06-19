class CreateSkalaUserNotes < ActiveRecord::Migration
  def change
    create_table :skala_user_notes do |t|
      t.references :user

      t.string     :record_id
      t.string     :scope_id
      t.text       :value, limit: 1073741823

      t.timestamps
    end

    add_index :skala_user_notes, :record_id
    add_index :skala_user_notes, :user_id
  end
end
