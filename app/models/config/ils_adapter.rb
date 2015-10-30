class Config
  class IlsAdapter
    include ActiveModel::Model

    attr_accessor :class_name
    attr_accessor :config
    attr_accessor :i18n_key
    attr_accessor :id
    attr_accessor :options
    attr_accessor :search_engine_adapter

    def i18n_key
      instance.i18n_key
    end

    def instance
      @instance ||= self.class_name.constantize.new(self.options)
    end

    def search_engine_adapter
      @config.find_search_engine_adapter(@search_engine_adapter)
    end
  end
end
