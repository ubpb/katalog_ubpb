atom_feed(
  language: "de-DE",
  schema_date: "2015",
  url: searches_url(search_request: @search_request, scope: current_scope, format: :atom),
  root_url: searches_url(search_request: @search_request, scope: current_scope)
) do |feed|
  feed.title "Suchergebnisse für #{@search_request.queries.map{|q| q.query}.join()}"
  feed.author do
    feed.name "Universitätsbibliothek Paderborn"
  end

  if @search_result.present? && @search_result.hits.present?
    @search_result.hits.each do |hit|
      feed.entry(hit, url: record_url(hit.record.id, scope: current_scope)) do |entry|
        entry.title(title(hit.record))

        content = ""

        #if (is_part_of = is_part_of(hit.record, scope: current_scope)).present?
        #  content << "<div>#{is_part_of.html_safe}</div>"
        #end

        if (info = additional_record_info(hit.record)).present?
          content << "<div>#{info}</div>"
        end

        #if journal_holdings = journal_holdings(hit.record)
        #  content << "<div>Bestand UB: #{journal_holdings}</div>"
        #end

        entry.content(content, type: "html")
      end
    end
  end
end
