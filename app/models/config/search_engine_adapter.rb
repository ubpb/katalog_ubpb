class Config
  class SearchEngineAdapter
    include ActiveModel::Model

    attr_accessor :class_name
    attr_accessor :config
    attr_accessor :i18n_key
    attr_accessor :id
    attr_accessor :options

    def i18n_key
      instance.i18n_key
    end

    def instance
      @instance ||= self.class_name.constantize.new(self.options)
    end
  end
end
