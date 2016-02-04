class UsersController < ApplicationController
  rescue_from NotAuthorizedError do
    flash[:error] = t(".not_authorized_error")
    redirect_to user_path
  end

  before_action :authenticate!, except: [:events]
  before_action { add_breadcrumb name: "users#show", url: user_path }

  layout "user"

  def show
    @user = current_user
  end

end
