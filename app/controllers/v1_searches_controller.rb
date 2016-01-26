# only for compatibility with version 1 of katalog
class V1SearchesController < ApplicationController

  before_action do
    if former_catalog_search?
      redirect_to_translated_searches_path
    end
  end

  def index
    redirect_to root_path # if not redirected before
  end

  def search
    flash[:notice] = t("v1_searches.redirected_from_old_permalink")

    if (search = V1Search.find_by_hashed_id(params[:id])) && former_catalog_search?(query = search.query)
      redirect_to_translated_searches_path(query)
    else
      redirect_to searches_path(scope: KatalogUbpb.config.scopes.first)
    end
  end

  def record
    record_id = params[:id]
    flash[:notice] = t("v1_searches.redirected_from_old_permalink")

    if record_id.upcase.starts_with?("PAD_ALEPH")
      # Local record
      redirect_to record_path(record_id.gsub(/PAD_ALEPH/i, ""), scope: "local")
    else
      # Primo central record
      redirect_to record_path(record_id, scope: "primo_central")
    end

  end

  private

  def former_catalog_search?(params = self.params)
    KatalogUbpb::PermalinkTranslator.recognizes?(params)
  end

  def redirect_to_translated_searches_path(params = self.params)
    new_params = KatalogUbpb::PermalinkTranslator.translate(params)
    redirect_to searches_path(new_params)
  end

end
