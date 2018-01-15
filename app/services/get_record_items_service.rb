class GetRecordItemsService < Servizio::Service
  include AdapterRelatedService
  include InstrumentedService
  include RecordRelatedService

  JOURNAL_SIGNATURE_PATTERN = /\d\d[a-zA-Z]\d{1,4}/ # don't use \w as it includes numbers

  attr_accessor :ils_adapter
  attr_accessor :record
  attr_accessor :record_id
  attr_accessor :search_engine_adapter

  alias_method :adapter,  :ils_adapter
  alias_method :adapter=, :ils_adapter=
  alias_method :id,       :record_id
  alias_method :id=,      :record_id=

  validates_presence_of :ils_adapter
  validates_presence_of :record_id

  def record_id
    @record_id || @record.try(:id)
  end

  def call
    ils_adapter_result = ils_adapter.get_record_items(record_id)

    if ils_adapter_result.items.any?
      update_records!(ils_adapter_result, search_engine_adapter)
    elsif record && journal_signature?(record.signature) && !journal_stock?(record)
      ils_adapter_result.items << KatalogUbpb::Item.new(
        availability: :unknown,
        item_status: "-",
        record: record,
        signature: record.signature,
        status: :unknown
      )
    end

    strip_source!(ils_adapter_result)
  rescue Skala::Adapter::Error
    errors.add(:call, :failed) and return nil
  end

  private

  def journal_stock?(record)
    record.journal_stock.present?
  end

  def journal_signature?(signature)
    signature.try(:[], JOURNAL_SIGNATURE_PATTERN).present?
  end
end
