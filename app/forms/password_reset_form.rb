class PasswordResetForm < ApplicationForm

  attr_accessor :ilsid

  validates :ilsid, presence: true
  validate :check_user

  def initialize(attributes = {}, ils_adapter:)
    super(attributes)
    @ils_adapter = ils_adapter
  end

  def user
    @user ||= GetUserService.new(adapter: @ils_adapter, username: ilsid).call.result
    (@user && @user.is_a?(User)) ? @user : nil
  end

private

  def check_user
    if user
      if user.email_address.present?
        return true
      else
        errors.add(:ilsid, "Für dieses Konto ist keine E-Mail Adresse konfiguriert. Um Ihr Passwort zurückzusetzen wenden Sie sich bitte an die Ortsleihe.")
        return false
      end
    else
      errors.add(:ilsid, "Nummer unbekannt")
      return false
    end
  end

end
