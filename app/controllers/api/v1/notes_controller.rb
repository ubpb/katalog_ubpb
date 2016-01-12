class Api::V1::NotesController < Api::V1::ApplicationController
  def create
    call_service(CreateNoteService,
      record_id: params[:record_id],
      scope_id: params[:scope_id],
      user_id: params[:user_id],
      value: params[:value],
      on_success: -> (called_operation) do
        @note = called_operation.result
      end
    )
  end

  def update
    call_service(UpdateNoteService,
      id: params[:id],
      new_value: params[:value],
      on_success: -> (called_operation) do
        @note = called_operation.result
      end
    )
  end

  def destroy
    call_service(DeleteNoteService, id: params[:id])
  end
end
