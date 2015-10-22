module ResourceLinksHelper

  def resource_links(hit)
    links = [*hit.fields["resource_link"]]
    LinksFilter.new(links).links
  end

  def vpn_info
    # In case of request from an ip rage outside of Uni Paderborn
    # show hint about VPN.
    unless request_from_campus?
      content_tag(:span) do
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
        BLACKLIST.any?{|i| i.match(link)}
      end
    end

    def sort_by_priority(links)
      links.sort do |a, b|
        ia = PRIORITY_LIST.find_index{|regexp| regexp.match(a)} || 1000
        ib = PRIORITY_LIST.find_index{|regexp| regexp.match(b)} || 1000
        ia <=> ib
      end
    end

  end

end
