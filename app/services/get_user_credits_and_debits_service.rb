class GetUserCreditsAndDebitsService < Servizio::Service
  include CachingService
  include UserRelatedService

  attr_accessor :ils_adapter
  attr_accessor :search_engine_adapter

  alias_method  :adapter,  :ils_adapter
  alias_method  :adapter=, :ils_adapter=

  validates_presence_of :ils_adapter
  validates_presence_of :ilsuserid

  def call
    get_user_cash_result = ils_adapter.get_user_cash(ilsuserid)
    credits = get_user_cash_result.try(:credits) || []
    debits = get_user_cash_result.try(:debits) || []

    if (credits.present? || debits.present?) && search_engine_adapter
      search_result = SearchRecordsService.call(
        adapter: search_engine_adapter,
        search_request: Skala::SearchRequest.new(
          queries: [
            {
              type: "ordered_terms", # TODO: no need for ordered_terms here, use unscored_terms
              field: "id", # TODO: should be ils_record_id
              terms: [credits.map(&:ils_record_id), debits.map(&:ils_record_id)].flatten(1)
            }
          ],
          size: credits.try(:length).to_i + debits.try(:length).to_i
        )
      )

      [credits, debits].flatten.compact.each do |_cash|
        if hit = search_result.hits.find { |_hit| _hit.fields["id"] == _cash.ils_record_id } # TODO: hit.fields["ils_record_id"]
          _cash.search_engine_record_id = hit.id
          _cash.signature ||= hit.fields["signature"]
          _cash.title ||= hit.fields["title"]
        end
      end
    end

    [credits, debits]
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
