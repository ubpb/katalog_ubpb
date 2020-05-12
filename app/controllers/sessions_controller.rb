class SessionsController < ApplicationController

  before_action :add_breadcrumb

  def new
  end

  def create
    username = params.dig "user", "username"
    password = params.dig "user", "password"

    if username.present? && password.present?
      auth_result = Ils[:default].authenticate_user(params["user"]["username"], params["user"]["password"])

      if auth_result == true
        ils_user = Ils[:default].get_user(username)
        db_user  = create_or_update_user!(ils_user)
        session[:current_user_id] = db_user.id
        redirect_to(user_path)
      else
        flash[:error] = "FOO"
        render :new
      end
    else
      flash[:error] = "FOO"
      render :new
    end
  rescue
    flash[:error] = "BAR"
    render :new
  end

  def destroy
    reset_session
    redirect_to root_path
  end

private

  def create_or_update_user!(ils_user)
    User.transaction do
      user = User.where(
        'ilsuserid=:userid OR ilsusername=:username', userid: ils_user.id, username: ils_user.id
      ).first_or_initialize

      user.attributes = {
        :ilsuserid     => ils_user.id,
        :ilsusername   => ils_user.id,
        :email_address => ils_user.email,
        :first_name    => ils_user.firstname,
        :last_name     => ils_user.lastname
      }
      user.save!

      user
    end
  end

end
