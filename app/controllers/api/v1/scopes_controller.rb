class Api::V1::ScopesController < Api::V1::ApplicationController
  def index
    @scopes = Application.config.scopes
  end
end
