class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  def katalog_layout
    "application"
  end
end
