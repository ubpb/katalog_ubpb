class Api::V1::Records::ItemsController < Api::V1::ApplicationController
  def index
    Skala::GetRecordItemsService.new(
      ils_adapter: Skala.config.ils_adapter.instance,
      record_id: params[:record_id]
    ).call!.tap do |operation|
      if operation.succeeded?
        @items = operation.result
      end
    end
  end
end
