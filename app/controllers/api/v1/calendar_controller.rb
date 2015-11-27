require 'digest/sha2'

class Api::V1::CalendarController < Api::ApplicationController
  include IcalDsl

  before_filter :authenticate!

  def show
    loans         = get_loans
    hold_requests = get_hold_requests
    provisions    = hold_requests.select{|hold_request| hold_request.end_hold_date.present? && hold_request.end_hold_date >= Time.zone.today}

    loans_records      = get_records(loans.map(&:record_id))
    provisions_records = get_records(provisions.map(&:record_id))

    response.headers["X-Robots-Tag"] = "all"

    respond_to do |format|
      format.json do
        head :not_implemented
      end

      format.text do
        render text: to_raw_ics(
          group_loans_by_due_date(loans),
          group_provisions_by_due_date(provisions),
          loans_records,
          provisions_records)
      end

      format.ics do
        render text: to_raw_ics(
          group_loans_by_due_date(loans),
          group_provisions_by_due_date(provisions),
          loans_records,
          provisions_records)
      end
    end
  end

  private

  def to_raw_ics(loans_by_due_date, provisions_by_due_date, loans_records, provisions_records)
    loans_url         = File.join(root_url, "/user/loans")
    holds_url         = File.join(root_url, "/user/holds")
    info_url          = "http://goo.gl/Evx6Ls"
    fees_url          = "http://goo.gl/BvYujI"
    opening_hours_url = "http://goo.gl/tfhFbh"

    Calendar.build do
      item "VERSION", "2.0"
      item "PRODID", "-//Universitätsbibliothek Paderborn//Katalog//DE"
      item "METHOD", "PUBLISH"
      item "CALSCALE", "GREGORIAN"
      item "X-WR-CALNAME", "UB Paderborn - Leihfristen"
      item "X-WR-TIMEZONE", "Europe/Berlin"

      #
      # Leihfristen
      #
      loans_by_due_date.each_key do |due_date|
        loans  = loans_by_due_date.fetch(due_date)
        titles = loans.each_with_index.map do |loan, i|
          record    = loans_records[loan.record_id]
          title     = cached_view_context.title(record)
          year      = cached_view_context.date_of_publication(record)
          signature = cached_view_context.signature(record)

          "#{i+1}. #{[title, year, "Signatur: #{signature}"].map(&:presence).join(', ')}"
        end.join('\n')

        description = <<-EOS
Die Leihfrist für die folgenden Medien endet heute. Ab morgen fallen Gebühren an.
Bitte nutzen Sie Ihr Bibliothekskonto um Details zu sehen und um ggf. Verlängerungen zu veranlassen.

#{titles}

Bibliothekskonto: #{loans_url}
Informationen zu Ausleihe, Verlängerung und Rückgabe von Medien: #{info_url}
Informationen zu Gebühren: #{fees_url}
Bitte beachten Sie unsere Öffnungszeiten: #{opening_hours_url}
EOS
        block "VEVENT" do
          item "UID", (Digest::SHA2.new << "loans-#{due_date.to_s}").to_s
          item "CLASS", "PUBLIC"
          item "TRANSP", "TRANSPARENT"
          item "DTSTART;VALUE=DATE", due_date
          item "DTEND;VALUE=DATE", due_date + 1.day
          item "SEQUENCE", "0"
          item "SUMMARY;LANGUAGE=de", "Leihfrist endet"
          item "DESCRIPTION", description, fold: true, escape: true
          item "X-MICROSOFT-CDO-BUSYSTATUS", "FREE"
          item "X-MICROSOFT-CDO-IMPORTANCE", "1"
          item "X-MICROSOFT-DISALLOW-COUNTER", "FALSE"
          item "X-MS-OLK-CONFTYPE", "0"

          #
          # Alarms will be ignored by most apps (ical (by default), Outlook) when
          # reading calendars from web resources due to security reasons (no one likes
          # to wake up at night because of silly alarm settings).
          # Outlook for example dosen't import alarms at any case. See
          # http://answers.microsoft.com/en-us/office/forum/office_2010-outlook/outlook-calendar-import-with-remindersalarms/7d5f9690-7309-4a4d-8b4c-788c093b5b36
          #
          #block "VALARM" do
          #  item "ACTION", "DISPLAY"
          #  item "DESCRIPTION", "Reminder"
          #  item "TRIGGER;VALUE=DATE-TIME", due_date.to_datetime.in_time_zone.change(hour: 9)
          #end
          #
          #block "VALARM" do
          #  item "ACTION", "DISPLAY"
          #  item "DESCRIPTION", "Reminder"
          #  item "TRIGGER;VALUE=DATE-TIME", due_date.to_datetime.in_time_zone.change(hour: 9) - 1.day
          #end
          #
          #block "VALARM" do
          #  item "ACTION", "DISPLAY"
          #  item "DESCRIPTION", "Reminder"
          #  item "TRIGGER;VALUE=DATE-TIME", due_date.to_datetime.in_time_zone.change(hour: 9) - 7.days
          #end
        end
      end

      #
      # Bereitstellungen
      #
      provisions_by_due_date.each_key do |due_date|
        provisions = provisions_by_due_date.fetch(due_date)
        titles = provisions.each_with_index.map { |provision, i|
          "#{i+1}. #{[provision.title, provision.year, "Signatur: #{provision.signature}"].map(&:presence).join(', ')}"
        }.join('\n')

        description = <<-EOS
Die folgenden vorgemerkten Medien stehen für Sie zur Abholung bereit.
Bitte nutzen Sie Ihr Bibliothekskonto um Details zu sehen und ggf. um Vormerkungen zu löschen, sollten Sie die Medien nicht mehr benötigen.

#{titles}

Bibliothekskonto: #{holds_url}
Informationen zu Ausleihe, Verlängerung und Rückgabe von Medien: #{info_url}
Informationen zu Gebühren: #{fees_url}
Bitte beachten Sie unsere Öffnungszeiten: #{opening_hours_url}
EOS

        block "VEVENT" do
          item "UID", (Digest::SHA2.new << "provisions-#{due_date.to_s}").to_s
          item "CLASS", "PUBLIC"
          item "TRANSP", "TRANSPARENT"
          item "DTSTART;VALUE=DATE", Time.zone.today
          item "DTEND;VALUE=DATE", due_date + 1
          item "SEQUENCE", "0"
          item "SUMMARY;LANGUAGE=de", "Bereitstellung von Vormerkungen"
          item "DESCRIPTION", description, fold: true, escape: true
          item "X-MICROSOFT-CDO-BUSYSTATUS", "FREE"
          item "X-MICROSOFT-CDO-IMPORTANCE", "1"
          item "X-MICROSOFT-DISALLOW-COUNTER", "FALSE"
          item "X-MS-OLK-CONFTYPE", "0"

          #block "VALARM" do
          #  item "ACTION", "DISPLAY"
          #  item "DESCRIPTION", "Reminder"
          #  item "TRIGGER;VALUE=DATE-TIME", Time.zone.today.to_datetime.in_time_zone.change(hour: 9)
          #end
        end
      end
    end
  end

  def group_loans_by_due_date(loans)
    group = {}
    loans.each { |loan| (group[loan.due_date] ||= []) << loan }
    group
  end

  def group_provisions_by_due_date(provisions)
    group = {}
    provisions.each { |provision| (group[provision.end_hold_date] ||= []) << provision }
    group
  end

  def get_loans
    GetUserLoansService.call(
      adapter: KatalogUbpb.config.ils_adapter.instance,
      user: current_user
    )
  end

  def get_hold_requests
    GetUserHoldRequestsService.call(
      adapter: KatalogUbpb.config.ils_adapter.instance,
      user: current_user
    )
  end

  def get_records(ils_ids)
    search_result = SearchRecordsService.call(
      adapter: KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance,
      search_request: @search_request = Skala::Adapter::Search::Request.new(
        queries: [
          {
            type: "ordered_terms",
            field: "id",
            terms: ils_ids
          }
        ],
        size: ils_ids.length
      )
    )

    search_result.hits.each_with_object({}) do |_hit, _hash|
      _hash[_hit.fields["id"]] = _hit
    end
  end

  def cached_view_context
    # view_context instantiates a new view instance per call,
    # so we cache it
    @_cashed_view_context ||= view_context
  end

end
