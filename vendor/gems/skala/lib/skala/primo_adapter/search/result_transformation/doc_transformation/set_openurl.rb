require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetOpenurl < Transformator::Transformation::Step

  def call
    openurl = transformation.read_source_values(".//LINKS/openurl").first
    if openurl.present?
      openurl = remove_language_param(openurl)
      openurl = fix_rfr_id(openurl)
      target.record.openurl = openurl
    end
  end

private

  # Remove the language param to force the default language
  # TODO: UBPB setting: Move to custom adapter
  def remove_language_param(openurl)
    openurl.split('&').map{|e| e.gsub(/req\.language=.+/, 'req.language=')}.join('&')
  end

  # See: https://github.com/ubpb/issues/issues/59
  def fix_rfr_id(openurl)
    openurl.gsub(/primo3-Article/i, "primo3-article")
  end

end
