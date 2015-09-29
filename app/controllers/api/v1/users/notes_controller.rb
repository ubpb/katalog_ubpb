class Api::V1::Users::NotesController < Api::V1::UsersController
  def create
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))

    if user.nil?
      head :not_found and return
    end

    create_note = Skala::User::CreateNote.new({
      record: Skala::Record.new(record_params),
      scope: Skala.config.find_search_scope(params[:scope_id]),
      user: user,
      value: params[:value]
    })

    if can?(:call, operation = create_note)
      if operation.valid?
        if operation.call!.succeeded?
          render "note", locals: { note: operation.result }
        else
          head operation.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end

  def update
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))
    note = user.try(:notes).try(:find_by_id, params[:id])

    if user.nil? || note.nil?
      head :not_found and return
    end

    update_note = Skala::User::UpdateNote.new({
      note: note,
      values: note_params
    })

    if can?(:call, operation = update_note)
      if operation.valid?
        if operation.call!.succeeded?
          render "note", locals: { note: operation.result }
        else
          head operation.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end

  def destroy
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))
    note = user.try(:notes).try(:find_by_id, params[:id])

    if user.nil? || note.nil?
      head :not_found and return
    end

    destroy_entry = Skala::User::DeleteNote.new({
      note: note
    })

    if can?(:call, destroy_entry)
      if destroy_entry.valid?
        if destroy_entry.call!.succeeded?
          head :ok
        else
          head destroy_entry.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end

  #
  private
  #
  def record_params
    HashWithIndifferentAccess.new({
      id: params[:record_id]
    })
  end

  def note_params
    HashWithIndifferentAccess.new({
      value: params[:value]
    })
  end
end
