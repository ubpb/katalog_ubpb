require_relative "../aleph_adapter"

module Skala
  class AlephAdapter::GetRecord
    def initialize(adapter)
      @adapter = adapter
    end

    def call(record_id)
      get_record = @adapter.restful_api.record(record_id).get(view: :full)

      {
        "_type" => "record",
        "_id" => record_id,
        "fields" => {
          "record" => "#{get_record[/<?.*?>/]}#{WeakXml.find("<record>", get_record).to_s}"
        },
        "_source" => get_record
      }
    end
  end
end
