require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  AddSortByList < Transformator::Transformation::Step

  #
  # SortField is optional, so we have to add it on the fly if necessary
  #
  def call
    source.sort.try(:first).try do |_sort_request|
      primo_search_request = transformation.inner_search_request.locate("PrimoSearchRequest").first
      insert_sort_by_node(primo_search_request, _sort_request)
    end
  end

  private

  def insert_sort_by_node(primo_search_request, sort_request)
    # Order matters, SortField *must* be inserted after <Languages>
    index_of_languages = primo_search_request.nodes.index do |_node|
      _node.value == "Languages"
    end

    # primo can only handle *one* sort field
    sort_by_list = Ox.parse(
      <<-xml
        <SortByList>
          <SortField>#{sort_request.field}</SortField>
        </SortByList>
      xml
    )

    # insert the SortByList at the appropriate position
    primo_search_request.nodes.insert(index_of_languages + 1, sort_by_list)
  end
end
