class Note < ApplicationRecord

  # Relations
  belongs_to :user

  # Validations
  validates_presence_of   :user
  validates_presence_of   :record_id
  validates_uniqueness_of :record_id, scope: :user_id
  validates_presence_of   :value

end
