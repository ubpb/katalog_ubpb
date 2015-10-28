class GetUserService < Servizio::Service
  attr_accessor :adapter
  attr_accessor :id
  attr_accessor :username

  def call
    if id.present?
      User.find_by(id: id)
    elsif username.present?
      if adapter.blank?
        User.find_by(ilsuserid: username)
      else
        get_user_result = adapter.get_user(username)

        if get_user_result.present?
          # keep in mind that the adapter result id is the determining ils user id, *not* username, especially for create
          User.find_or_create_by(ilsuserid: get_user_result.id).tap do |_user|
            _user.update_attributes!(
              cash_balance: get_user_result.cash_balance,
              email_address: get_user_result.email_address,
              expiry_date: get_user_result.expiry_date,
              first_name: get_user_result.first_name,
              last_name: get_user_result.last_name
            )
          end
        else
          errors[:call] = :user_not_found
        end
      end
    end
  rescue
    errors[:call] = :failed and return nil
  end
end