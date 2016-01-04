=begin
#  Client-side
#
#  $.ajax
#    url: Routes.api_v1_partial_path("searches/index/hit")
#    type: "POST"
#    contentType: "application/json"
#    dataType: "text"
#    data: JSON.stringify(
#      watch_lists: @get("watch_lists")
#    )
#    success: (data) =>
#      debugger
# 
#  Routing
#
#    post "partials/:path", to: "partials#show", as: :partial, constraints: { path: /.+/ }
#
class Api::V1::PartialsController < Api::V1::ApplicationController
  def show
    binding.pry
    w = render_to_string(partial: params[:path], locals: partial_locals)
    binding.pry
  end

  private

  def partial_locals
    params.permit!.to_h.with_indifferent_access.tap do |_params_hash|
      _params_hash.extract!(:action, :controller, :partial, :path)
    end
  end
end
=end
