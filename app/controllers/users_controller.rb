class UsersController < ApplicationController

  before_action :authenticate!
  before_action { add_breadcrumb name: "users#show", url: user_path }

  layout "users"

  rescue_from NotAuthorizedError do
    flash[:error] = t(".not_authorized_error")
    redirect_to user_path
  end

  def show
    @user = current_user
  end

end
