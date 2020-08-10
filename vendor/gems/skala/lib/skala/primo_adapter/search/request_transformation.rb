require "transformator/transformation"
require_relative "../search"

class Skala::PrimoAdapter::Search::RequestTransformation < Transformator::Transformation
  extend Forwardable

  require_directory "#{File.dirname(__FILE__)}/request_transformation"

  attr_accessor :adapter
  attr_accessor :inner_search_request
  attr_accessor :on_campus

  delegate [:languages, :locations, :institution, :enable_cdi] => :adapter

  def call(source, adapter, options = {})
    self.adapter = adapter
    self.on_campus = options.try(:[], :on_campus)
    super(source, options)
  end

  sequence [
    SetupTarget,
    SetupInnerSearchRequest,
    EnableCDI,
    [
      [
        AddQueries,
        SetStartIndex,
        SetBulkSize,
        SetLanguages,
        AddSortByList,
        SetLocations,
        SetOnCampus
      ],
      SetInstitution
    ],
    ToggleBoolOperator,
    EmbedInnerSearchRequest,
    SerializeTargetAsXml
  ]
end
