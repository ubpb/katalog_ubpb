module ResourceLinksHelper

  def resource_links(record, default_link_only: false)
    openurl            = record.openurl
    is_online_resource = record.carrier_type == "online_resource"
    is_data_storage    = record.carrier_type == "data_storage"

    if openurl.present?
      link_to(openurl, target: "_blank") do
        if record.fulltext_available
          "#{fa_icon "external-link"} Direkt zur Online-Resource".html_safe
        else
          "#{fa_icon "external-link"} Direkt zur Online-Resource (möglicherweise kein Volltext verfügbar)".html_safe
        end
      end
    elsif is_online_resource || is_data_storage
      links = record.resource_link
      links = LinksFilter.new(links).links

      if links.present?
        if default_link_only || links.size == 1
          link_to(links.first.url, target: "_blank") do
            "#{fa_icon "external-link"} Direkt zur Online-Resource".html_safe
          end
        else
          content_tag(:ul) do
            links.map do |link|
              content_tag(:li) do
                link_to(link.url, target: "_blank")
              end
            end.join.html_safe
          end
        end
      end
    end
  end

  def vpn_info
    # In case of request from an ip rage outside of Uni Paderborn
    # show hint about VPN.
    unless request_from_campus?
      content_tag(:div, class: "vpn-info") do
        content_tag(:i, "", class: "fa fa-exclamation-triangle") <<
        content_tag(:span, " Gegebenenfalls nur ") <<
        content_tag(:a, "via VPN erreichbar", href: "http://imt.uni-paderborn.de/netzbetrieb/vpn-installieren", target: "_blank")
      end.html_safe
    end
  end

  def request_from_campus?
    IPAddr.new("131.234.0.0/16") === (request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip)
  end

private

  class LinksFilter
    BLACKLIST = [
      /ebrary.com/,
      /contentreserve.com/
    ]

    PRIORITY_LIST = [
      /digital\.ub\.uni-paderborn\.de/,
      /digital\.ub\.upb\.de/,
      /uni-paderborn\.de/,
      /upb\.de/,
      /uni-regensburg\.de/,
      /ebscohost/,
      /jstor/,
      /nbn-resolving\.de/
    ]

    attr_reader :links

    def initialize(links)
      @links = links
      @links = apply_blacklist(@links)
      @links = sort_by_priority(@links)
    end

  protected

    def apply_blacklist(links)
      links.reject do |link|
        BLACKLIST.any?{|i| i.match(link.url)}
      end
    end

    def sort_by_priority(links)
      links.sort do |a, b|
        ia = PRIORITY_LIST.find_index{|regexp| regexp.match(a.url)} || 1000
        ib = PRIORITY_LIST.find_index{|regexp| regexp.match(b.url)} || 1000
        ia <=> ib
      end
    end

  end

end
