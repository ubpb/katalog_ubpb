class Note < ActiveRecord::Base

  # Relations
  belongs_to :user

  # Validations
  validates_presence_of   :user
  validates_presence_of   :recordid
  validates_uniqueness_of :recordid, scope: :user_id
  validates_presence_of   :value

end
