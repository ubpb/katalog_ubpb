class AddScopeIdToNotes < ActiveRecord::Migration
  class Note < ActiveRecord::Base
  end

  LOCAL_RECORDS_PREFIX = "PAD_ALEPH"
  LOCAL_SCOPE_ID = "local"
  PRIMO_CENTRAL_SCOPE_ID = "primo_central"

  def up
    add_column :notes, :scope_id, :string
    Note.reset_column_information

    with_each_note do |_note|
      if _note.record_id.start_with?(LOCAL_RECORDS_PREFIX)
        _note.record_id = _note.record_id.sub(LOCAL_RECORDS_PREFIX, "")
        _note.scope_id = LOCAL_SCOPE_ID
      else
        _note.scope_id = PRIMO_CENTRAL_SCOPE_ID
      end
    end
  end

  def down
    with_each_note do |_note|
      if _note.scope_id == LOCAL_SCOPE_ID
        _note.record_id = "#{LOCAL_RECORDS_PREFIX}#{_note.record_id}"
      end
    end

    remove_column :notes, :scope_id
  end

  private

  def with_each_note
    return unless block_given?

    Note.find_in_batches(batch_size: batch_size = 100) do |_notes|
      puts "Processing #{batch_size} notes"

      transaction do
        _notes.each do |_note|
          yield _note
          _note.save
        end
      end
    end
  end
end
