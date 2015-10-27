class Config
  include ActiveModel::Model

  attr_accessor :ils_adapter
  attr_accessor :search_scopes

  def ils_adapter=(value)
    @ils_adapter = IlsAdapter.new(value)
  end

  def search_scopes=(value)
    @search_scopes = value.keys.map do |scope_id|
      SearchScope.new(value[scope_id].merge(id: scope_id))
    end
  end

  def find_search_scope(scope_id)
    search_scopes.find{|scope| scope.id == scope_id.to_s}
  end


  class IlsAdapter
    include ActiveModel::Model

    attr_accessor :class_name
    attr_accessor :i18n_key
    attr_accessor :options

    def i18n_key
      instance.i18n_key
    end

    def instance
      @instance ||= self.class_name.constantize.new(self.options)
    end
  end


  class SearchScope
    include ActiveModel::Model

    attr_accessor :facets
    attr_accessor :id
    attr_accessor :search_engine_adapter
    attr_accessor :searchable_fields
    attr_accessor :sortable_fields

    def search_engine_adapter=(value)
      @search_engine_adapter = SearchEngineAdapter.new(value)
    end

    def to_param
      id
    end

    class SearchEngineAdapter
      include ActiveModel::Model

      attr_accessor :class_name
      attr_accessor :i18n_key
      attr_accessor :options

      def i18n_key
        instance.i18n_key
      end

      def instance
        @instance ||= self.class_name.constantize.new(self.options)
      end
    end

  end

end
