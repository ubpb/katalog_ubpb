class Skala::Record
  require_relative "record/is_part_of"
  require_relative "record/relation"
  require_relative "record/link"
  require_relative "record/identifier"

  include Virtus.model

  # A unique id within the source system
  attribute :id, String
  # The title
  attribute :title, String
  # Creators / Contributors
  attribute :creator, Array[String]
  # The year of publication
  attribute :year_of_publication, String
  # Date when the record was created in the source system
  attribute :created_at, Date
  # Edition
  attribute :edition, String
  # Languages
  attribute :language, Array[String]
  # Publisher
  attribute :publisher, Array[String]
  # Abstract
  attribute :abstract, String
  # Notes
  attribute :note, Array[String]
  # Descriptions
  attribute :description, Array[String]
  # ISBNs
  attribute :isbn, Array[String]
  # ISSNs
  attribute :issn, Array[String]
  # Identifier (TODO: Move ISBN & ISSN into indetifier)
  attribute :identifier, Array[Identifier]
  # Source
  attribute :source, String
  # Content type (e.g. bibliography, textbook, dissertation, ...)
  attribute :content_type
  # Media type (e.g. monograph, journal, newspaper, ...)
  attribute :media_type
  # Carrier type (e.g. online_resource, data_storage, ...)
  attribute :carrier_type
  # Format
  attribute :format, String
  # Resource links
  # => DEPRECATED. USE resource_links and fulltext_links
  attribute :resource_link, Array[Link]
  # Links to Table of contents
  # => DEPRECATED. USE resource_links and fulltext_links
  attribute :toc_link, Array[Link]
  # Resource links (non fulltext links). E.g. Inhaltsverzeichnis, Kapitel, Cover, etc.
  attribute :resource_links, Array[Link]
  # Fulltext links (only URLs, no labels)
  attribute :fulltext_links, Array[String]
  # Part of...
  attribute :is_part_of, Array[IsPartOf]
  # Relation
  attribute :relation, Array[Relation]
  # Subject
  attribute :subject, Array[String]

  # the default virtus implementation does not handle missing methods
  def [](key)
    try(key)
  end
  #
  # TODO: UB Paderborn specific attributes will be
  # moved into Ubpb::Record < Skala::Record in the furture
  #

  attribute :hbz_id, String
  attribute :signature, String
  attribute :journal_holdings, Array[String]
  attribute :journal_stock, Array[Hash]
  attribute :notation, Array[String]
  attribute :is_superorder, Boolean, default: false
  attribute :is_secondary_form, Boolean, default: false
  attribute :openurl, String
  attribute :fulltext_available, Boolean, default: true

  attribute :secondary_form_year_of_publication, String
  attribute :secondary_form_preliminary_phrase, String
  attribute :secondary_form_isbn, Array[String]
  attribute :secondary_form_publisher, Array[String]
  attribute :secondary_form_physical_description, String
  attribute :secondary_form_is_part_of, Array[IsPartOf]

  def journal_stock=(values)
    super(values.is_a?(Array) ? values : [values].compact.presence)
  end

  # END: UB Paderborn specific attributes

end
