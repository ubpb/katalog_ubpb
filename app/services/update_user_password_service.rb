class UpdateUserPasswordService < Servizio::Service
  include DistinctnessValidator # @provides .validates_distinctness_of
  include InstrumentedService
  include UserRelatedService    # @provides #user

  attr_accessor :adapter
  attr_accessor :current_password
  attr_accessor :new_password
  attr_accessor :new_password_confirmation

  validates_presence_of :adapter
  validates_presence_of :current_password
  validates_presence_of :new_password
  validates_presence_of :new_password_confirmation
  validates_length_of   :new_password, minimum: 6
  validates_confirmation_of :new_password
  validates_distinctness_of :new_password, from: :current_password
  validates_presence_of :user
  validate :current_password_is_correct

  def call
    adapter.update_user(type: "password", user: user, new_password: new_password)
  rescue Skala::Adapter::Error
    errors.add(:base, :failed) and return nil
  end

  #
  private
  #
  def current_password_is_correct
    unless AuthenticateUserService.call(adapter: adapter, username: user.ilsusername, password: current_password, parents: parents << self.class)
      errors.add(:current_password, :must_be_correct)
    end
  end
end
