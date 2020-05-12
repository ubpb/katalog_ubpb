class SessionsController < ApplicationController

  before_action :add_breadcrumb
  before_action :capture_return_path

  def create
    return redirect!(cancel: true) if params[:cancel].present?

    username = params.dig "user", "username"
    password = params.dig "user", "password"

    if username.present? && password.present?
      auth_result = Ils[:default].authenticate_user(username, password)

      if auth_result == true
        ils_user = Ils[:default].get_user(username)
        db_user  = create_or_update_user!(ils_user)
        session[:current_user_id] = db_user.id
        redirect!
      else
        flash[:error] = t(".create.failed")
        render :new
      end
    else
      redirect_to(new_session_path)
    end
  rescue
    flash[:error] = t(".create.error")
    render :new
  end

  def destroy
    reset_session
    redirect_to(root_path)
  end

private

  def create_or_update_user!(ils_user)
    User.transaction do
      user = User.where(
        'ilsuserid=:userid OR ilsusername=:username', userid: ils_user.id, username: ils_user.id
      ).first_or_initialize

      user.update_attributes!(
        :ilsuserid     => ils_user.id,
        :ilsusername   => ils_user.id,
        :email_address => ils_user.email,
        :first_name    => ils_user.firstname,
        :last_name     => ils_user.lastname
      )

      user
    end
  end

  def capture_return_path
    return_path = sanitize_return_path(params[:return_to])
    redirect    = params[:redirect] == "true"

    if return_path.present?
      session[:return_to] = {
        return_path: return_path,
        redirect: redirect
      }
    end
  end

  def redirect!(cancel: false)
    return_to   = session.delete(:return_to) || {}
    return_path = return_to["return_path"]
    redirect    = return_to["redirect"]

    if cancel
      return_path ||= root_path
      redirect = true
    end

    if return_path && redirect == true
      redirect_to(return_path)
    else
      flash[:success] = render_to_string(partial: "success_flash_message", locals: {return_path: return_path})
      redirect_to(user_path)
    end
  end

end
