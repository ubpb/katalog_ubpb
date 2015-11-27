class Config
  class SearchEngineAdapter
    include ActiveModel::Model

    attr_accessor :class_name
    attr_accessor :config
    attr_accessor :i18n_key
    attr_accessor :id
    attr_accessor :options

    def i18n_key
      @i18n_key || instance.class.to_s.underscore.gsub("/", ".")
    end

    def instance
      @instance ||= self.class_name.constantize.new(self.options)
    end
  end
end
