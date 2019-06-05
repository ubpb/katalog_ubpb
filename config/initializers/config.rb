module KatalogUbpb
  def self.config
    yaml = (YAML.load(ERB.new(File.new("#{Rails.root}/config/config.yml").read).result) || {})[Rails.env] || {}
    @config ||= Config.new(yaml)
  end

  def self.config=(value)
    @config = Config.new(value)
  end
end
