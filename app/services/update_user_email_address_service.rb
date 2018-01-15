class UpdateUserEmailAddressService < Servizio::Service
  include InstrumentedService
  include UserRelatedService # @provides #user

  attr_accessor :adapter
  attr_accessor :current_email_address
  attr_accessor :new_email_address

  def current_email_address
    @current_email_address || user.try(:email_address)
  end

  validates_presence_of :adapter
  validates_presence_of :user
  validates_presence_of :new_email_address

  def call
    adapter.update_user(type: "email", user: user, new_email_address: new_email_address).tap do |_adapter_result|
      if _adapter_result == true
        User.find_by_ilsuserid(user.ilsuserid).tap do |_user|
          _user.update_attributes(email_address: new_email_address)
        end
      end
    end
  rescue Skala::Adapter::Error
    errors.add(:call, :failed) and return nil
  end
end
