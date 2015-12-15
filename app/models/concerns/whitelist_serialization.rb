module WhitelistSerialization
  extend ActiveSupport::Concern

  class_methods do
    def serialization_whitelist(attributes = nil)
      if attributes
        @serialization_whitelist = Array(attributes)
      else
        @serialization_whitelist
      end
    end
  end

  def serializable_hash(options = nil)
    options ||= {}
    options[:only] = Array(options[:only]).concat(self.class.serialization_whitelist || [:id])
    super(options.presence)
  end
end
