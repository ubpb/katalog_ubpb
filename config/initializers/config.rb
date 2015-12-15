module KatalogUbpb
  def self.config
    @config ||= Config.new(Rails.application.config_for(:config))
  end

  def self.config=(value)
    @config = Config.new(value)
  end
end
