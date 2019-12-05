class KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings::Mapping
  def initialize(field_mapping, &block)
    @callable = block
    @original_field_name = field_mapping.keys.first
    @new_field_name = field_mapping.values.first
  end

  def call!(object, search_request = nil)
    changed = false

    if @original_field_name.present?
      if object.respond_to?(:field)
        if object.field == @original_field_name && object.respond_to?(:field=)
          changed = true
          object.field = @new_field_name
        end
      elsif object.respond_to?(:fields)
        if object.fields.include?(@original_field_name) && object.respond_to?(:fields=)
          object.fields = object.fields.map do |_field_name|
            if _field_name == @original_field_name
              changed = true
              @new_field_name
            else
              _field_name
            end
          end
        end
      end
    end

    if changed
      search_request.try(:changed=, true)

      if @callable.present?
        if @callable.arity == 1
          @callable.call(object)
        else
          @callable.call(object, search_request)
        end
      end
    end
  end
end
