module DistinctnessValidator
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def validates_distinctness_of(*attr_names)
      # from rails/activemodel/lib/active_model/validations/with.rb
      options = attr_names.extract_options!.symbolize_keys
      attr_names.flatten!
      options[:attributes] = attr_names

      # anonymous validator class
      validator = Class.new(ActiveModel::EachValidator) do
        def validate_each(record, attribute, value)
          if value == record.send(options[:from])
            record.errors.add(attribute, :distinctness, options)
            record.errors.add(options[:from], :distinctness, options)
          end
        end
      end

      validates_with validator, options
    end
  end  
end
