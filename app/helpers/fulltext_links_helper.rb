module FulltextLinksHelper

  def fulltext_links(record, default_link_only: false, print_mode: false)
    openurl            = record.try(:openurl)
    is_online_resource = record.try(:carrier_type) == "online_resource"
    is_data_storage    = record.try(:carrier_type) == "data_storage"

    if openurl.present?
      if print_mode
        link_to(openurl)
      else
        link_to(openurl, target: "_blank") do
          if record.fulltext_available
            "#{fa_icon "external-link"} Direkt zur Online-Ressource".html_safe
          else
            "#{fa_icon "external-link"} Direkt zur Online-Ressource (mögl. kein Volltext verfügbar)".html_safe
          end
        end
      end
    elsif is_online_resource || is_data_storage
      links = record.resource_link
      links = LinksFilter.new(links).links

      if links.present?
        if print_mode
          links.map do |link|
            link_to(link.url)
          end.join("<br/>").html_safe
        else
          if default_link_only || links.size == 1
            link_to(links.first.url, target: "_blank") do
              "#{fa_icon "external-link"} Direkt zur Online-Ressource".html_safe
            end
          else
            content_tag(:ul) do
              links.map do |link|
                content_tag(:li) do
                  link_to(link.url, link.url, target: "_blank")
                end
              end.join.html_safe
            end
          end
        end
      end
    end
  end

  def vpn_info
    # In case of request from an ip rage outside of Uni Paderborn
    # show hint about VPN.
    unless on_campus?(request.remote_ip)
      content_tag(:div, class: "vpn-info") do
        content_tag(:a, href: "http://www.ub.uni-paderborn.de/recherche/hinweise-zur-nutzung-der-elektronischen-angebote/elektronische-informationsmedien-im-fernzugriff-vpn-shibboleth/", target: "_blank") do
          '<i class="fa fa-exclamation-triangle"></i> Gegebenenfalls nur via VPN oder Shibboleth (DFN-AAI) erreichbar'.html_safe
        end
      end.html_safe
    end
  end

private

  class LinksFilter
    BLACKLIST = [
      /ebrary.com/,
      /contentreserve.com/,
      /digitale-objekte.hbz-nrw.de/
    ]

    PRIORITY_LIST = [
      /bibid=UBPB/,
      /bib_id=ub_pb/,
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
