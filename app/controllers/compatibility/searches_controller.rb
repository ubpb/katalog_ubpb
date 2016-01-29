class Compatibility::SearchesController < ApplicationController
  skip_before_action :add_breadcrumb, :only => [:index, :show]

  def index
    if former_catalog_search?
      log_former_catalog_search!
      flash[:notice] = t(".please_update_url")
      redirect_to_translated_searches_path
    else
      redirect_to root_path
    end
  end

  def show
    logger.info "Former (saved) search called, ip: #{request.ip || 'nil'}, referer: #{request.referer || 'nil'}, params: #{params}"
    flash[:notice] = t("v1_searches.redirected_from_old_permalink")

    if (search = V1Search.find_by_hashed_id(params[:id])) && former_catalog_search?(query = search.query)
      redirect_to_translated_searches_path(query)
    else
      redirect_to root_path
    end
  end

  private

  def former_catalog_search?(params = self.params)
    KatalogUbpb::PermalinkTranslator.recognizes?(params)
  end

  def log_former_catalog_search!
    logger.info { "Former search request submitted, ip: #{request.ip || 'nil'}, referer: #{request.referer || 'nil'}, params: #{params}" }
  end

  def redirect_to_translated_searches_path(params = self.params)
    new_params = KatalogUbpb::PermalinkTranslator.translate(params)
    redirect_to searches_path(new_params)
  end

end
