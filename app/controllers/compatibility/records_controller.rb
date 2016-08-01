class Compatibility::RecordsController < ApplicationController
  skip_before_action :add_breadcrumb, :only => [:show], raise: false

  def show
    record_id = params[:id]
    flash[:notice] = t(".please_update_url")

    if record_id.upcase.starts_with?("PAD_ALEPH")
      # Local record
      redirect_to record_path(record_id.gsub(/PAD_ALEPH/i, ""), scope: "local")
    else
      # Primo central record
      redirect_to record_path(record_id, scope: "primo_central")
    end
  end

end
