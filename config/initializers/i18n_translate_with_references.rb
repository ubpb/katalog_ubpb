module I18n
  class << self
    alias_method :original_translate, :translate

    def translate(key, options = {})
      # e.g. ~> some.other.key
      if (original_translation = original_translate(key, options)).is_a?(String)
        original_translation.gsub(/~>\s?([^\s]*)/) do |_matched_string|
          translate($1, options)
        end
      else
        original_translation
      end
    end
  end
end
