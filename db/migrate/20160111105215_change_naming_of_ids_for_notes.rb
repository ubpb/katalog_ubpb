class ChangeNamingOfIdsForNotes < ActiveRecord::Migration
  def change
    change_table :notes do |t|
      t.rename :recordid, :record_id
    end
  end
end
