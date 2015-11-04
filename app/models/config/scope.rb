class Config
  class Scope
    include ActiveModel::Model

    attr_accessor :config
    attr_accessor :facets
    attr_accessor :id
    attr_accessor :ils_adapter
    attr_accessor :search_engine_adapter
    attr_accessor :searchable_fields
    attr_accessor :sortable_fields

    def to_param
      id
    end

    def ils_adapter
      @config.find_ils_adapter(@ils_adapter)
    end

    def search_engine_adapter
      @config.find_search_engine_adapter(@search_engine_adapter)
    end

  end
end
