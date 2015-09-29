class ApplicationController::BreadcrumbTrail
  include Enumerable

  def initialize(breadcrumbs = [], root = nil)
    @breadcrumbs = breadcrumbs
    @root = root
    normalize!
  end

  def each
    @breadcrumbs.each do |_breadcrumb|
      yield({
        "name" => _breadcrumb["name"],
        "url" => ActiveSupport::Gzip.decompress(Base64.strict_decode64(_breadcrumb["url"]))
      })
    end
  end

  def <<(hash)
    @breadcrumbs << breadcrumb_factory(hash)
    normalize!
  end

  alias_method :push, :<<

  #
  private
  #
  def breadcrumb_factory(hash)
    {
      # stored values from the session always have string keys, so we also use string keys here
      "name" => hash["name"] || hash[:name],
      "url" => Base64.strict_encode64(ActiveSupport::Gzip.compress(hash["url"] || hash[:url]))
    }
  end

  def collapse!
    result = []

    # remove duplicates
    loop do
      result << @breadcrumbs.shift
      break if @breadcrumbs.any? do |_breadcrumb|
        _breadcrumb["name"] == result.last["name"]
      end || @breadcrumbs.empty?
    end

    @breadcrumbs.clear.concat(result)
  end

  def ensure_uniqueness!
    @breadcrumbs.uniq! { |_breadcrumb| _breadcrumb["name"] }
  end

  def ensure_user_show_if_user_action!
    if _user_action_index = @breadcrumbs.find_index { |_breadcrumb| _breadcrumb["name"].start_with?("user") }
      binding.pry
      if @breadcrumbs[_user_action_index - 1]["name"] != "user#show"
        @breadcrumbs.insert(_user_action_index - 1,
          breadcrumb_factory({
            "name" => "users#show",
            "url" => Skala::Core::Engine.routes.url_helpers.user_path
          })
        )
      end
    end
  end

  def ensure_root!
    if @root
      unless @breadcrumbs.first["name"] == @root["name"]
        @breadcrumbs.unshift(breadcrumb_factory(@root))
      end
    end
  end

  def normalize!
    ensure_root!
    ensure_uniqueness!
    ensure_user_show_if_user_action!
    collapse!

    # remove everything before the first user#... except the first one
    #if index = result.find_index { |_breadcrumb| _breadcrumb["name"].start_with?("users") }
    #  result = [result[0]].concat(result.slice(index..-1))
    #end
  end
end
