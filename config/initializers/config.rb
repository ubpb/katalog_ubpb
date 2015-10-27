module KatalogUbpb
  def self.config
    @config ||= Skala::Config.new(Rails.application.config_for(:config))
  end
end
