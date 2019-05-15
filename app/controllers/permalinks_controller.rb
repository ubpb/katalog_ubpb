class PermalinksController < ApplicationController

  def show
    add_breadcrumb name: "permalinks#show"

    if permalink = Permalink.find_by(key: params[:id])
      @permalink = permalink
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  end

  def create
    max_tries ||= 5

    key            = SecureRandom.hex(16)
    scope          = params[:scope]&.presence
    search_request = params[:search_request]&.presence

    permalink = Permalink.new(key: key, scope: scope, search_request: search_request)

    if permalink.save
      redirect_to(permalink_path(permalink))
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  rescue ActiveRecord::RecordNotUnique
    if (max_tries -= 1).zero?
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    else
      retry
    end
  end

  def resolve
    if permalink = Permalink.find_by(key: params[:id])
      path = searches_path(scope: permalink.scope, search_request: permalink.search_request)
      redirect_to(path)
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  end

end
