require "active_support"
require "active_support/core_ext"
require "virtus"

if ::Object.const_defined?("Rails")
  require_relative "skala/engine"
end

module Skala
  # virtus objects do not deep_dup correctly, so the have to include this
  module DeepDupable
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end
  end

  require_relative "skala/adapter"
  require_relative "skala/aleph_adapter"
  require_relative "skala/elasticsearch_adapter"
  require_relative "skala/primo_adapter"

  require_relative "skala/hold_request"
  require_relative "skala/item"
  require_relative "skala/loan"
  require_relative "skala/inter_library_loan"
  require_relative "skala/record"
  require_relative "skala/transaction"
end

# patch Virtus to not serialize unset lazy attributes
class Virtus::AttributeSet
  def get(object)
    each_with_object({}) do |attribute, attributes|
      name = attribute.name

      if attribute.public_reader? && (!attribute.lazy? || attribute.defined?(object))
        attributes[name] = object.__send__(name)
      end
    end
  end
end
