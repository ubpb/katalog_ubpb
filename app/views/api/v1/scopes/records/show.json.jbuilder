if @records.length == 0

elsif @records.length == 1
  compacted_record = @records.first.as_json.select { |_,_value| _value.present? }
  json.extract!(compacted_record, *compacted_record.keys)
else
  json.array! @records do |_record|
    compacted_record = _record.as_json.select { |_,_value| _value.present? }
    json.extract!(compacted_record, *compacted_record.keys)
  end
end
