class Api::V1::Records::ItemsController < Api::V1::ApplicationController
  def index
    @items = GetRecordItemsService.call(
      adapter: KatalogUbpb.config.ils_adapter.instance,
      id: params[:record_id]
    ).items
  end
end
