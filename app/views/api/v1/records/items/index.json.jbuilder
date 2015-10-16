json.array! @items do |_item|
  %w(availability).each do |_property|
    if _item.respond_to?(_property)
      json.set!(_property, _item.public_send(_property))
    end
  end
end
