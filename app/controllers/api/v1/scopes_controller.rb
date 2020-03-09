class Api::V1::ScopesController < Api::V1::ApplicationController
  def index
    @scopes = KatalogUbpb.config.scopes
  end
end
