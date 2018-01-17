class GetUserService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :api_key
  attr_accessor :id
  attr_accessor :username

  def call
    if id.present?
      User.find_by(id: id)
    elsif api_key.present?
      User.find_by(api_key: api_key)
    elsif username.present?
      get_user_result = adapter.get_user(username)

      if get_user_result.present?
        # keep in mind that the adapter result id is the determining ils user id, *not* username, especially for create
        create_or_update_user!(get_user_result)
      else
        errors.add(:base, :user_not_found)
      end
    end
  rescue
    errors.add(:base, :failed) and return nil
  end

private

  def create_or_update_user!(user_result)
    User.transaction do
      user = User.where(
        'ilsuserid=:userid OR ilsusername=:username', userid: user_result.id, username: user_result.username
      ).first_or_initialize

      user.attributes = user_attributes(user_result)
      user.save!

      user
    end
  end

  def user_attributes(user_result)
    {
      :ilsuserid     => user_result.id,
      :ilsusername   => user_result.username,
      :email_address => user_result.email_address,
      :expiry_date   => user_result.expiry_date,
      :first_name    => user_result.first_name,
      :last_name     => user_result.last_name
    }
  end

end
