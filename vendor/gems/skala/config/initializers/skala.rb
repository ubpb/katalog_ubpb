module Skala
  def self.config
    @config ||= Skala::Config.new(Rails.application.config_for(:skala))
  end
end
