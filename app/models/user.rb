class User < ActiveRecord::Base

  # Relations
  has_many :notes, dependent: :destroy
  has_many :watch_lists, dependent: :destroy

  # Validations
  validates_presence_of   :ilsuserid
  validates_uniqueness_of :ilsuserid
  validates :pseudonym, uniqueness: true, allow_nil: true, format: { with: /\A[a-z0-9\-_]+\Z/}


  def ilsuserid=(value)
    super(value.try(:to_s).try(:upcase))
  end

end
