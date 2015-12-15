class User < ActiveRecord::Base
  include WhitelistSerialization

  serialization_whitelist [
    :id, :first_name, :email_address, :cash_balance, :expiry_date, :ilsuserid,
    :pseudonym, :number_of_hold_requests, :number_of_loans
  ]

  # Relations
  has_many :notes, dependent: :destroy
  has_many :watch_lists, dependent: :destroy

  # Validations
  validates_presence_of   :ilsuserid
  validates_uniqueness_of :ilsuserid
  validates_uniqueness_of :api_key
  validates :pseudonym, uniqueness: true, allow_nil: true, format: { with: /\A[a-z0-9\-_]+\Z/}

  def cash_balance
    super.try(:to_f) # in order to make BigDecimal a float to the outside
  end

  def name
    [first_name, last_name].compact.join(" ").presence
  end

  def name_reversed
    [last_name, first_name].compact.join(", ").presence
  end

  def number_of_hold_requests
    super || 0
  end

  def number_of_loans
    super || 0
  end

  def api_key
    read_attribute(:api_key) || recreate_api_key!
  end

  def recreate_api_key!
    key = SecureRandom.hex(16)
    update_attribute(:api_key, key)
    key
  end
end
