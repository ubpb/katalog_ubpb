require_relative "../search"

# these mappings should be applied *in order* given by the array
KatalogUbpb::UbpbElasticsearchAdapter::Search::INDEX_FIELD_MAPPINGS ||= [
  {
    "cdate"   => "creationdate_search",
    "creator" => "creator_contributor_search",
    "isbn"    => "isbn_search",
    "issn"    => "issn",
    "lsr05"   => "ht_number",
    "lsr10"   => "signature_search",
    "lsr15"   => "notation",
    "lsr34"   => "publisher",
    "sub"     => "subject_search",
    "title"   => "title_search",
    "toc"     => "toc",
    # facets
    "lang"    => "language_facet",
    "tlevel"  => {
      "materialtyp_facet" => {
        "online_resources" => "online_resource"
      }
    },
    # sort
    "lso03"    => "notation_sort",
    "lso48"    => { "cataloging_date" => "desc" },
    "lso49"    => { "volume_count_sort2" => "asc" },
    "lso50"    => { "volume_count_sort2" => "desc" },
    "rank"     => "_score",
    "screator" => "creator_contributor_facet",
    "scdate"   => { "creationdate_facet" => "desc" },
    "stitle"   => "title_sort"
  }
]
