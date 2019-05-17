class AddLastResolvedAtToPermalinks < ActiveRecord::Migration[5.1]
  def change
    add_column :permalinks, :last_resolved_at, :datetime, null: true
  end
end
