class UpdateUserEmailAddressService < Servizio::Service
  include UserRelatedService # @provides #ilsuserid, #user

  attr_accessor :adapter
  attr_accessor :current_email_address
  attr_accessor :new_email_address

  def current_email_address
    @current_email_address || user.try(:email_address)
  end

  validates_presence_of :adapter
  validates_presence_of :ilsuserid
  validates_presence_of :new_email_address

  def call
    adapter.update_user(ilsuserid, email_address: new_email_address).tap do |_adapter_result|
      if _adapter_result == true
        User.find_by_ilsuserid(ilsuserid).tap do |_user|
          _user.update_attributes(email_address: new_email_address)
        end
      end
    end
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
