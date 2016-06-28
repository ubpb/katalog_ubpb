class PasswordForm < ApplicationForm

  attr_accessor :password, :password_confirmation

  validates :password, presence: true, confirmation: true, length: {minimum: 6}

end
