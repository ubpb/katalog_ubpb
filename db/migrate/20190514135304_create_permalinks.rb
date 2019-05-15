class CreatePermalinks < ActiveRecord::Migration[5.1]
  def change
    create_table :permalinks do |t|
      t.string :key, index: true, unique: true, null: false
      t.string :scope, null: false
      t.text   :search_request, null: false, limit: 65535 # MYSQL type TEXT
      t.timestamps
    end
  end
end
