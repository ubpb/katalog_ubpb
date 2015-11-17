# The whole "let's overwrite .new" stuff is to make this work with inherited
# classes. If you inheritate from a service, overwrite #call and include this
# concern, you probably want to instrument the derived service, not the one
# you inheritated from.
module InstrumentedService
  extend ActiveSupport::Concern

  module InstrumentedCall
    def call(*args)
      ActiveSupport::Notifications.instrument("service_called.katalog_ubpb", service: self.class, parents: parents) do
        super
      end
    end
  end

  included do
    class << self
      alias_method :new_before_instrumented_service, :new
    end

    def self.new(*args, &block)
      (obj = new_before_instrumented_service(*args, &block)).singleton_class.send(:prepend, InstrumentedCall)
      return obj
    end
  end

  def parents
    @parents || []
  end

  def parents=(value)
    @parents = value
  end
end
