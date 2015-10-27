class WatchListEntry < ActiveRecord::Base

  # Relations
  belongs_to :watch_list

  # Validations
  validates_presence_of   :watch_list
  validates_presence_of   :scopeid
  validates_presence_of   :recordid
  validates_uniqueness_of :recordid, scope: :watch_list_id

end
