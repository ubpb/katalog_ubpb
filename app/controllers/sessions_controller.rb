class SessionsController < ApplicationController

  skip_before_action :add_breadcrumb, :only => [:new]

  def create
    @authenticate_user = AuthenticateUserService.new(
      authenticate_user_params.merge(
        adapter: KatalogUbpb.config.ils_adapter.instance
      )
    )

    if @authenticate_user.valid?
      if @authenticate_user.call!.succeeded?
        if @authenticate_user.result == true
          user = GetUserService.call(
            get_user_params.merge(
              adapter: KatalogUbpb.config.ils_adapter.instance
            )
          )

          session[:user_id] = user.id
          redirect_to user_path
        else
          flash.now[:error] = t(".failed")
          render action: :new
        end
      else
        flash.now[:error] = t(".error")
        render action: :new
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

  def get_user_params
    params.require(:authenticate_user).permit(:username)
  end

end
