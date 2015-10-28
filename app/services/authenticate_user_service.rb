class AuthenticateUserService < Servizio::Service
  attr_accessor :adapter
  attr_accessor :username
  attr_accessor :password

  validates_presence_of :adapter
  validates_presence_of :username
  validates_presence_of :password

  def call
    adapter.authenticate_user(username, password)
  rescue
    errors[:call] = :failed and return nil
  end
end
