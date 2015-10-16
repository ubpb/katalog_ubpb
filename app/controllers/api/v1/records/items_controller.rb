class Api::V1::Records::ItemsController < Api::V1::ApplicationController
  def index
    @items = Skala::GetRecordItemsService.call(
      adapter: Skala.config.ils_adapter.instance,
      id: params[:record_id]
    ).items
  end
end
