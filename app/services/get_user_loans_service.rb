class GetUserLoansService < Servizio::Service
  include CachingService
  include InstrumentedService
  include UserRelatedService

  attr_accessor :ils_adapter
  attr_accessor :search_engine_adapter

  alias_method :adapter,  :ils_adapter
  alias_method :adapter=, :ils_adapter=

  validates_presence_of :ils_adapter
  validates_presence_of :ils_user_id

  def call
    ils_adapter.get_user_loans(ilsuserid).try(:loans).tap do |_loans|
      if _loans.present? && search_engine_adapter
        search_result = SearchRecordsService.call(
          adapter: search_engine_adapter,
          parents: parents << self.class,
          search_request: Skala::SearchRequest.new(
            queries: [
              {
                type: "ordered_terms", # TODO: no need for ordered_terms here, use unscored_terms
                field: "ils_record_id",
                terms: _loans.map(&:ils_record_id)
              }
            ],
            size: _loans.length.to_i
          )
        )

        _loans.each do |_loan|
          if hit = search_result.hits.find { |_hit| _hit.fields["ils_record_id"] == _loan.ils_record_id }
            _loan.search_engine_record_id = hit.id
            _loan.signature = hit.fields["signature"]
            _loan.title = hit.fields["title"]
          end
        end
      end
    end
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
