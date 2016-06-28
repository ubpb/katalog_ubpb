class User < ActiveRecord::Base
  include WhitelistSerialization

  serialization_whitelist [
    :id, :first_name, :email_address, :cash_balance, :expiry_date, :ilsuserid, :pseudonym
  ]

  # Relations
  has_many :notes, dependent: :destroy
  has_many :watch_lists, dependent: :destroy

  # Validations
  validates_presence_of   :ilsuserid
  validates_uniqueness_of :ilsuserid
  validates_uniqueness_of :api_key
  validates :pseudonym, uniqueness: true, allow_nil: true, format: { with: /\A[a-z0-9\-_]+\Z/}

  def name
    [first_name, last_name].compact.join(" ").presence
  end

  def name_reversed
    [last_name, first_name].compact.join(", ").presence
  end

  def api_key
    read_attribute(:api_key) || recreate_api_key!
  end

  def recreate_api_key!
    key = SecureRandom.hex(16)
    update_attribute(:api_key, key)
    key
  end

  def password_reset_token
    read_attribute(:password_reset_token) || recreate_password_reset_token!
  end

  def recreate_password_reset_token!
    token = SecureRandom.hex(16)
    update_attributes(
      password_reset_token: token,
      password_reset_token_created_at: Time.zone.now
    )
    token
  end

  def clear_password_reset_token!
    update_attributes(
      password_reset_token: nil,
      password_reset_token_created_at: nil
    )
  end

end
