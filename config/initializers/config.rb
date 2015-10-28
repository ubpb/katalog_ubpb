module KatalogUbpb
  def self.config
    @config ||= Config.new(Rails.application.config_for(:config))
  end
end
