class UsersController < ApplicationController
  before_action :authenticate!, except: [:events]
  before_action :except => [:create, :update, :destroy] do
    breadcrumbs.clear
    add_breadcrumb(name: "users#show", url: user_path)
    add_breadcrumb
  end

  layout "user"

  def show
    @user = current_user
  end

  #
  private
  #
  def on_denial(operation)
    flash[:error] = t(".access_denied")
    redirect_to user_path
  end

  def on_error(operation)
    flash[:error] = t(".error")
    redirect_to user_path
  end
end
