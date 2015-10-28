
module ApplicationHelper
  include FontAwesome::Rails::IconHelper

  def flash_message_class(type)
    case type.to_sym
      when :alert
        "alert alert-warning"
      when :error
        "alert alert-danger"
      when :notice
        "alert alert-info"
      when :success
        "alert alert-success"
      else
        "alert #{type.to_s}"
    end
  end

  def ensure_array(value)
    [value].flatten(1).compact
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

  def value_or_default(value, default: "–")
    value.presence || default
  end

  def ractive_component(ractive_class, options = {}, &block)
    tag_options = {
      "data-ractive-class" => ractive_class,
      "data-ractive-options" => options.to_json,
      "type" => "text/ractive"
    }

    tag_text = capture(&block) if block_given?

    content_tag(:script, tag_text, tag_options)
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
