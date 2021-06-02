desc "Fix CDI watch list entries"
task :fix_cdi_watch_list_entries => :environment do
  adapter = KatalogUbpb.config.scopes
    .find{|s| s.id == "primo_central"}
    .search_engine_adapter
    .instance

  index   = 0

  pci_record_ids = WatchListEntry
    .where(scope_id: "primo_central")
    .where(pci_cdi_migration: nil)
    .where("record_id not like 'cdi_%'")
    .order(:record_id)
    .pluck(:record_id)
    .uniq

  total = pci_record_ids.count

  pci_record_ids.each_slice(5) do |pci_record_ids|
    results = Parallel.map(pci_record_ids, in_threads: 5) do |pci_record_id|
      search_request = Skala::Adapter::Search::Request.new(
        queries: [
          {
            type: "ids",
            query: pci_record_id
          }
        ]
      )

      hit = adapter.search(search_request, on_campus: true).hits.first

      if cdi_record_id = hit&.record&.id
        {
          success: true,
          pci_record_id: pci_record_id,
          cdi_record_id: cdi_record_id
        }
      else
        {
          success: false,
          pci_record_id: pci_record_id,
          cdi_record_id: nil
        }
      end
    end

    results.each do |result|
      index += 1

      rel = WatchListEntry
        .where(scope_id: "primo_central")
        .where(record_id: result[:pci_record_id])

      if result[:success]
        rel.update_all(
          record_id: result[:cdi_record_id],
          pci_cdi_migration: true
        )

        puts "SUCCESS (#{index}/#{total}): #{result[:pci_record_id]} => #{result[:cdi_record_id]}"
      else
        rel.update_all(
          pci_cdi_migration: false
        )

        puts "ERROR (#{index}/#{total}): #{result[:pci_record_id]} => NULL"
      end
    end

    sleep(rand(1.0..2.0))
  end

  puts "DONE!"
  puts "Total: #{WatchListEntry.where(scope_id: "primo_central").where("pci_cdi_migration is not null").count}"
  puts "Success: #{WatchListEntry.where(scope_id: "primo_central").where(pci_cdi_migration: true).count}"
  puts "Error: #{WatchListEntry.where(scope_id: "primo_central").where(pci_cdi_migration: false).count}"
end
