require "nokogiri"

desc "Generate location lookup table"
task :generate_location_lookup_table => :environment do
  html = Nokogiri::HTML(Net::HTTP.get(URI("https://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-systemstellen/")))
  medienaufstellung = html.css("table")

  lookup_table = []

  medienaufstellung.css("tr")[1..-1].each do |_row|
    if (cells = _row.css("td")).length > 1
      notation_range_min, notation_range_max = cells[0].content.split("-").map(&:strip).map(&:presence)

      lookup_table.push({
        systemstellen: notation_range_min..(notation_range_max || notation_range_min),
        fachgebiet: cells[1].content&.gsub(/\u00a0/, " ")&.gsub(/\t/, '')&.strip,
        location: cells[2].content&.gsub(/\u00a0/, " ")&.gsub(/\t/, '')&.strip,
        standortkennziffern: cells[3].content.gsub(/[^\d,]/, "").split(","),
        fachkennziffern: if cells[4].content.present?
          first, last = cells[4].content.gsub(/[^\d-]/, "").split("-")
          last ||= first
          if first && last
            Range.new(first, last).to_a
          else
            []
          end
        end
      })
    end
  end

  if lookup_table.present?
    File.write(File.join(Rails.root, "app", "lib", "katalog_ubpb", "ubpb_aleph_adapter", "location_lookup_table.yml"), YAML.dump(lookup_table))
  end
end
