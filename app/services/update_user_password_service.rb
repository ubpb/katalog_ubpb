class UpdateUserPasswordService < Servizio::Service
  include DistinctnessValidator # @provides .validates_distinctness_of
  include UserRelatedService    # @provides #ilsuserid

  attr_accessor :adapter
  attr_accessor :current_password
  attr_accessor :new_password
  attr_accessor :new_password_confirmation

  validates_presence_of :adapter
  validates_presence_of :current_password
  validates_presence_of :new_password
  validates_presence_of :new_password_confirmation
  validates_confirmation_of :new_password
  validates_distinctness_of :new_password, from: :current_password
  validates_presence_of :ilsuserid
  validate :current_password_is_correct

  def call
    adapter.update_user(ilsuserid, password: new_password)
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end

  #
  private
  #
  def current_password_is_correct
    unless AuthenticateUserService.call(adapter: adapter, username: ilsuserid, password: current_password)
      errors.add(:current_password, :must_be_correct)
    end
  end
end
