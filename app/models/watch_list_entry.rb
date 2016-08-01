class WatchListEntry < ApplicationRecord

  # Relations
  belongs_to :watch_list

  # Validations
  validates_presence_of   :watch_list
  validates_presence_of   :scope_id
  validates_presence_of   :record_id
  validates_uniqueness_of :record_id, scope: :watch_list_id

  def scope
    Application.config.find_scope(scope_id)
  end

end
