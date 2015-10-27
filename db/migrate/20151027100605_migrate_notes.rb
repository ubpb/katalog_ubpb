class MigrateNotes < ActiveRecord::Migration
  def up
    remove_column :notes, :type
    rename_column :notes, :resourceid, :recordid
  end
end
