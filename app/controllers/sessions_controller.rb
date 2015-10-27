class SessionsController < ApplicationController

  skip_before_action :add_breadcrumb, :only => [:new]

  def create
    @authenticate_user = AuthenticateUserService.new(authenticate_user_params)

    if @authenticate_user.valid?
      @authenticate_user.call.try do |op|
        if op.succeeded?
          if op.result == true
            session[:user_id] = User.find_or_create_by(ilsuserid: op.username.upcase) do |user|
              # set attribute here...
            end.id

            redirect_to user_path
          else
            flash.now[:error] = t(".failed")
            render action: :new
          end
        else
          flash.now[:error] = t(".error")
          render action: :new
        end
      end
    else
      render action: :new
    end
  end

  def destroy
    reset_session # this is a rails method
    redirect_to root_path
  end

  def new
    @authenticate_user = AuthenticateUserService.new
  end

private

  def authenticate_user_params
    params.require(:authenticate_user).permit(:username, :password)
  end

end
