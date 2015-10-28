class SearchConverter
  #
  # When calling this from console, set Logger to /dev/null or to a file like this
  #
  # #> ActiveRecord::Base.logger = Logger.new File.open('log/convert_searches.log', 'w')
  #
  def self.do_it
    Search.find_each(batch_size: 20000) do |search|
      if search.query.is_a?(Hash) && search.query.key?('q')
        original_updated_at = search.updated_at

        (new_query = search['query'].clone)['query_terms'] = [{
          'if' => search['query']['if'].present? ? search['query']['if'] : 'any',
          'po' => search['query']['po'].present? ? search['query']['po'] : 'contains',
          'q'  => search['query']['q']
        }]

        new_query.delete_if { |k,v| [:q, :if, :po].include? k.to_sym }

        new_query['scope'] = 'catalog' unless search['query']['scope'].present?
        new_query['sf']    = 'rank'    unless search['query']['sf'].present?

        search.update_attribute :query, new_query
        search.update_attribute :updated_at, original_updated_at
      end
    end
  end
end
