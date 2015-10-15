require "nokogiri"

desc "Generate location lookup table"
task :generate_location_lookup_table => :environment do
  html = Nokogiri::HTML(Net::HTTP.get(URI("http://www.ub.uni-paderborn.de/lernen_und_arbeiten/bestaende/medienaufstellung-systemstelle.shtml")))
  medienaufstellung = html.css("#content > table")

  lookup_table = []

  medienaufstellung.css("tr")[2..-1].each do |_row|
    if (cells = _row.css("td")).length > 1
      notation_range_min, notation_range_max = cells[0].content.split("-").map(&:strip)

      lookup_table.push({
        systemstellen: notation_range_min..(notation_range_max || notation_range_min),
        fachgebiet: cells[1].content,
        ebene: cells[2].content,
        standortkennziffern: cells[3].content.gsub(/P/, "").split(",").map(&:strip),
        fachkennziffern: cells[4].content.split("-").map(&:strip)
      })
    end
  end

  if lookup_table.present?
    File.write(File.join(Rails.root, "lib", "katalog_ubpb", "ubpb_aleph_adapter", "location_lookup_table.yml"), YAML.dump(lookup_table))
  end
end
