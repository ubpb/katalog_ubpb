module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    before_action :add_breadcrumb, :except => [:create, :update, :destroy]
    helper_method :breadcrumbs
  end

  def add_breadcrumb(name: nil, url: request.fullpath)
    name ||=
    begin
      sanitized_controller_name = view_context.controller.class.to_s
      .underscore
      .gsub(/_?controller_?/, "")
      .gsub("/", ".")

      "#{sanitized_controller_name}##{view_context.controller.action_name}"
    end

    breadcrumbs.push(name, url)
  end

  def breadcrumbs
    BreadcrumbTrail.new(
      session["breadcrumbs"] ||= [],
      {
        name: "homepage#show",
        url: root_path
      }
    )
  end

  class BreadcrumbTrail
    include Enumerable

    def initialize(breadcrumbs = [], root_breadcrumb = nil)
      @breadcrumbs = breadcrumbs
      @root_breadcrumb = root_breadcrumb

      if root_breadcrumb
        @root_breadcrumb = root_breadcrumb
        unshift(@root_breadcrumb[:name], @root_breadcrumb[:url])
        uniq!
      end
    end

    def breadcrumb_factory(name, url)
      # string keys are used for internal storage because they are saved to the
      # session and hashes saved to session are string key'ed anyway
      {
        "name" => name,
        "url" => Base64.strict_encode64(ActiveSupport::Gzip.compress(url))
      }
    end

    def each
      return enum_for(__method__) unless block_given?

      @breadcrumbs.each do |_breadcrumb|
        yield(
          {
            name: _breadcrumb["name"],
            url: ActiveSupport::Gzip.decompress(Base64.strict_decode64(_breadcrumb["url"]))
          }
        )
      end
    end

    def unshift(name, url)
      @breadcrumbs.unshift(breadcrumb_factory(name, url))
      self
    end

    def <<(name, url)
      new_breadcrumb = breadcrumb_factory(name, url)

      if index_of_existing_breadcrumb = @breadcrumbs.find_index do |_breadcrumb|
        _breadcrumb["name"] == new_breadcrumb["name"]
      end
        @breadcrumbs.slice!(index_of_existing_breadcrumb+1..-1)
      else
        @breadcrumbs << new_breadcrumb
      end

      self
    end

    alias_method :push, :<<

    def clear
      @breadcrumbs.clear
      @breadcrumbs << breadcrumb_factory(@root_breadcrumb[:name], @root_breadcrumb[:url]) if @root_breadcrumb
      self
    end

    def uniq!
      @breadcrumbs.uniq! { |_breadcrumb| _breadcrumb["name"] }
      self
    end
  end
end
