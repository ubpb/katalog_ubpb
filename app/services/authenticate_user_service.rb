class AuthenticateUserService < Servizio::Service
  attr_accessor :username
  attr_accessor :password

  validates_presence_of :username
  validates_presence_of :password

  def call
    ils_adapter_result = KatalogUbpb.config.ils_adapter.instance.authenticate_user(username, password)

    if ils_adapter_result.is_a?(StandardError)
      errors[:call] = :failed and return nil
    else
      ils_adapter_result
    end
  end
end
