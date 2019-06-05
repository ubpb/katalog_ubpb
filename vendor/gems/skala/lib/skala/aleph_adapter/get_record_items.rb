require "nokogiri"
require "skala/adapter/get_record_items"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::GetRecordItems < Skala::Adapter::GetRecordItems
  include module_parent::ResolveUser

  def call(document_number, options = {})
    document_base = options[:document_base] || @adapter.default_document_base
    record_id = "#{document_base}#{document_number}"
    resolved_user_id = resolve_user(options[:username]) if options[:username]

    aleph_options = { patron: resolved_user_id, view: :full }.compact
    raw_aleph_response = adapter.restful_api.record(record_id).items.get(aleph_options)

    if raw_aleph_response.include?("<error>")
      return nil
    else
      self.class::Result.new(
        items: Nokogiri::XML(raw_aleph_response).xpath("//item").map do |_item|
          {
            id: id(_item),
            availability: availability(_item),
            due_date: due_date(_item),
            expected_date: expected_date(_item),
            hold_request_can_be_created: hold_request_can_be_created(_item),
            item_status: item_status(_item),
            number_of_hold_requests: number_of_hold_requests(_item),
            note: note(_item),
            record: {
              id: document_number
            },
            status: status(_item)
          }
        end,
        source: raw_aleph_response
      )
    end
  end

  private

  def availability(item)
    case status(item)
      when :on_shelf, :reshelving then :available
      else :not_available
    end
  end

  def due_date(item)
    if status(item) == :loaned
      Date.strptime(item.at_xpath("./status").content[/\d\d\/\d\d\/\d\d/], "%d/%m/%y")
    end
  end

  def hold_request_can_be_created(item)
    if allowed = item.at_xpath("./info[@type='HoldRequest']/@allowed").try(:content).presence
      allowed == "Y"
    end
  end

  def id(item)
    item.attr("href")[/[^\/]+\Z/][/\A[^?]+/]
  end

  def expected_date(item)
    if status(item) == :expected
      Date.strptime(item.at_xpath("./status").content[/\d\d\/\d\d\/\d\d/], "%d/%m/%y")
    end
  end

  def item_status(item)
    item.at_xpath("./z30/z30-item-status").try(:content)
  end

  def number_of_hold_requests(item)
    if queue = item.at_xpath("./queue").try(:content).presence
      queue[/\A\d+/].try(:to_i) # example: "1 request(s) of 11 items."
    end || 0
  end

  def note(item)
    [
      item.at_xpath("./z30/z30-description").try(:content),
      item.at_xpath("./z30/z30-note-opac").try(:content)
    ]
    .map(&:presence)
    .compact
    .try do |_array|
      _array.length <= 1 ? _array.first : _array
    end
  end

  def status(item)
    aleph_status = item.at_xpath("./status").try(:content).try(:gsub, /requested/i, "") # remove requested states

    case aleph_status
      when ""                                     then :on_shelf                  # Exemplar steht im Regal
      when /on shelf/i                            then :on_shelf                  # Exemplar steht im Regal
      when /^\d\d\/\d\d\/\d\d/                    then :loaned                    # Exemplar ist entliehen
      when /Effective due date: \d\d\/\d\d\/\d\d/ then :loaned                    # Exemplar ist entliehen (Rückruf)
      when /reshelving/i                          then :reshelving                # Exemplar wird zurückgestellt
      when /on hold/i                             then :on_hold                   # Exemplar ist bereitgestellt
      when /expected/i                            then :expected                  # Exemplar wird erwartet (es kann dann noch ein Datum geben)
      when /claimed returned/i                    then :claimed_returned          # Exemplar ist angeblich zurück
      when /lost/i                                then :lost                      # Exemplar ist verloren gegangen
      else :unknown
    end
  end
end
