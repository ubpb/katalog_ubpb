class WatchList < ActiveRecord::Base

  # Relations
  belongs_to :user
  has_many   :watch_list_entries, dependent: :destroy

  # Validations
  validates_presence_of :user
  validates_presence_of :name

end
