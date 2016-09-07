module ApplicationHelper
  CLOSED_STOCK_THRESHOLD = "1985"
  JOURNAL_SIGNATURE_PATTERN = /\d\d[a-zA-Z]\d{1,4}/ # don't use \w as it includes numbers

  def async_content(identifier)
    content_tag(:div, class: "async-content-placeholder", "data-async-content" => identifier, style: "text-align: center") do
      concat content_tag(:i, "", class: "fa fa-spinner fa-spin", style: "font-size: 44px;")
      concat form_tag({controller: controller_path, action: action_name, async_content: identifier}, method: request.method.downcase.to_sym, remote: true)
    end
  end

  def javascript_event_handler(event_name)
    # "...(event)" is a js convention for passing events to inline js e.g. <a onclick="foo(event)")></a>
    [
      "window",
      controller_path.split("/").map(&:camelize).tap do |_elements|
        _elements.last << "Controller"
      end,
      event_name
    ]
    .flatten
    .join(".") << "(event)"
  end

  def journal_signature?(signature)
    signature.try(:[], JOURNAL_SIGNATURE_PATTERN).present?
  end

  def journal_locations(signature:, stock: nil)
    result = []

    if journal_signature?(signature)
      years = (stock || []).map { |element| element.split("-") }.flatten.map { |date| date[/\d{4}/] }

      if years.any? { |year| year > CLOSED_STOCK_THRESHOLD } || stock.blank?
        standortkennziffer = signature[/\AP\d+/].try(:[], /\d+/)
        fachkennziffer = signature.sub(/\AP\d+\//, "")[/\A\d+/]

        matching_row = LOCATION_LOOKUP_TABLE.find do |row|
          row[:standortkennziffern].try(:include?, standortkennziffer) &&
          (
            ["IEMAN", "IMT: Medien", "Zentrum für Sprachlehre"].include?(row[:location]) ||
            row[:fachkennziffern].try(:include?, fachkennziffer)
          )
        end

        result << matching_row[:location] if matching_row
      end

      if years.any? { |year| year <= CLOSED_STOCK_THRESHOLD }
        result.unshift("Magazin")
      end
    end

    result.uniq
  end

  def value_or_default(value, default: "–")
    value.presence || default
  end

  def ractive_component(ractive_class, options = {}, &block)
    ractive_tag(ractive_class, :script, options.merge(html_options: { type: "text/ractive" }), &block)
  end

  def ractive_tag(ractive_class, tag, options = {}, &block)
    (options = tag and tag = nil) if tag.is_a?(Hash)
    tag ||= :div

    html_options = options.extract!(:html_options)[:html_options]
    content_tag_options = {
      "data-ractive-class" => ractive_class,
      "data-ractive-options" => options.to_json
    }.merge(html_options || {})

    text = capture(&block) if block_given?
    content_tag(tag, text, content_tag_options)
  end

  def render_relative(relative_partial_path, options = {}, &block)
    calling_file_directory = @virtual_path.split("/")[0..-2].join("/")
    partial_path = File.join(calling_file_directory, relative_partial_path)
    render(partial_path, options, &block)
  end

  def responsive_table(&block)
    # http://stackoverflow.com/questions/5540709/how-does-a-helper-method-and-yield-to-a-block-in-rails-3
    table_html = capture(&block)
    table = Nokogiri::HTML(table_html)

    # Add some classes to the original table
    table.xpath("//table").add_class("hidden-xs")

    # create the table for xs
    table_heads = table.xpath("//th").map { |e| e.text }

    xs_table_builder = Nokogiri::HTML::Builder.new(encoding: "UTF-8") do |html|
      html.table(class: "table-striped cat-responsive-table hidden-lg hidden-md hidden-sm") do
        html.tbody do
          table.xpath("//tbody/tr").each do |tr|
            html.tr do
              html.td do
                html.ul do
                  tr.xpath("./td").each_with_index do |td, index| # each.with_index does not work here
                    html.li do
                      html.div(class: "table-head") { html.text table_heads[index] }
                      html.div(class: "table-data") do |table_data|
                        table_data << td.children.to_s
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    (table.root.to_s << xs_table_builder.doc.root.to_s).html_safe
  end
end
