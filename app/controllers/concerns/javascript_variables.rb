module JavascriptVariables
  extend ActiveSupport::Concern

  included do
    after_action do |*args|
      if @__client_memory_store__
        response.body = response.body.gsub(/<body[^>]*>/) do |match|
          "#{match}<script id=\"memory-store-initial-data\" type=\"application/json\">#{@__client_memory_store__.to_json}</script>"
        end
      end
    end

    helper_method :client_memory_store
  end

  def client_memory_store(name, value, options = nil)
    if value
      (@__client_memory_store__ ||= {})[name] = value.as_json(options)
    end

    "proxy(app.memory_store)"
  end
end
