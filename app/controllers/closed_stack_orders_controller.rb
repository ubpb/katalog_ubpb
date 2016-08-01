# Aufzurufende URL:
# den Reversproxy
# http(s):\\ubtesa.uni-paderborn.de/cgi-bin/magbest_via_primo?para1=wert1&para2=wert2&...&parax=wertx
# oder direkt den Aleph-Apache-Webserver
# http:\\ubtesa.uni-paderborn.de:8991/cgi-bin/magbest_via_primo?para1=wert1&para2=wert2&...&parax=wertx

# Parameter sind:
# ---------------

# name            Nachname, Vorname
# ausweis         die Ausweisnummer

# JCHECK          Jahrgangspruefung der Zeitschriften, wenn vorhanden wird geprueft

# m1              fuer die Signatur der ersten Monografie
# k1              fuer den Kurztitel der ersten Monografie

# m2              2. Monografie
# k2

# m3              3. Monografie
# k3

# m4              4. Monografie
# k4

# z1              fuer die erste Zeitschriftensignatur
# j1              fuer das Jahr
# b1              fuer den Band
# s1              fuer die Seite

# z2              2. Zeitschrift
# j2
# b2
# s2

# z3              3. Zeitschrift
# j3
# b3
# s3

# z4              4. Zeitschrift
# j4
# b4
# s4

# Beispielaufruf:
# ---------------
# http:\\ubtesa.uni-paderborn.de:8991/cgi-bin/magbest_via_primo?name=Nachname,Vorname&ausweis=PA1012345678&m1=M43654&k1=Vertraute+Fremde&JCHECK=


# Antworten des CGI-Scripts         Was soll es bedeuten?
# -------------------------         ---------------------
# erfolg                            Bestellung wurde angenommen

# fehler_nicht_schonwieder          Diese Bestellung wurde bereits aufgegeben!
#                                   Bitte erkundigen Sie sich ggf. an der Ortsleihtheke, wann die von Ihnen
#                                   gewuenschte Literatur abholbereit ist

# fehler_bestellangaben             Bitte geben Sie die Signatur des gewuenschten Exemplares an.

# fehler_jahrgang_band              Bitte geben Sie den Jahrgang und/oder Nummer des Bandes an.

# fehler_jahr_in_ebene              Sie haben einen Jahrgang ab 1987 eingegeben!
#                                   Diese Zeitschriftenbaende finden Sie in der Regel nicht im Magazin sondern in
#                                   den Fachbibliotheken. Wenn Sie sicher sind, dass sich der von Ihnen
#                                   benoetigte Band im Magazin befindet, schalten Sie bitte im Eingabeformular die
#                                   Jahrgangspruefung aus.

# fehler_jahrgang_falsch            Sie haben den Zeitschriftenjahrgang ist nicht richtig eingegeben!
#                                   Bitte geben Sie das Jahr vierstellig ein.
#                                   Bitte beachten Sie dabei:
#                                   Im Magazin sind nur Jahrgaenge bis 1986 untergebracht.
#                                   Neuere Zeitschriftenbaende finden Sie in den Fachbibliotheken.

# IPAdr_nicht_erlaubt               Zugriff von dieser IP nicht erlaubt



# HTML-Formular zum Testen:
# -------------------------
# http://ubtesa.uni-paderborn.de/lokadm/magbest_via_primo.htm

# Anzeige der aktuellen Magazinbestellungen
# -----------------------------------------
# http://ubtesa.uni-paderborn.de/cgi-bin/zeigemagbest



class ClosedStackOrdersController < ApplicationController
  include UrlUtils

  before_action :authenticate!
  before_action :setup
  before_action { add_breadcrumb name: "closed_stack_orders#new" }

  UNDEFINED_ERROR_MESSAGE = "Es ist ein Fehler bei der Magazinbestellung aufgetreten. Bitte versuchen Sie es erneut, oder wenden Sie sich an das Informationszentrum der Bibliothek."

  def new
  end

  def create
    if @m1 == "BYH1141" && @k1.blank?
      flash.now[:error] = "ACHTUNG!!! Sie bestellen gerade einen Mikrofiche. In diesem Fall tragen Sie bitte unbedingt den gewünschten Titel des Werkes ein."
      return render action: :new
    end

    url  = "#{KatalogUbpb.config.ils_adapter.options["x_services_url"]}/../cgi-bin/magbest_via_primo"
    options = {
      name: current_user.name_reversed,
      ausweis: current_user.ilsuserid,
      m1: @m1,
      k1: @k1,
      z1: @z1,
      j1: @j1,
      b1: @b1,
      s1: @s1
    }
    options["jcheck"] = "true" if @volume_check
    response_code = get_url(url, options)

    if response_code == "erfolg"
      flash[:success] = "Ihre Bestellung wurde erfolgreich abgeschlossen."
      redirect_to new_closed_stack_order_path
    else
      @error_message = case response_code
        when "fehler_nicht_schonwieder" then "Fehler: Diese Bestellung wurde bereits aufgegeben! Bitte erkundigen Sie sich ggf. an der Ortsleihtheke, wann die von Ihnen gewünschte Literatur abholbereit ist."
        when "fehler_bestellangaben"    then "Fehler: Bitte geben Sie die Signatur des gewünschten Exemplares an."
        when "fehler_jahrgang_band"     then "Fehler: Bitte geben Sie den Jahrgang und/oder Nummer des Bandes an."
        when "fehler_jahr_in_ebene"     then @volume_error = true ; "Fehler: Sie haben einen Jahrgang ab 1986 eingegeben! Diese Zeitschriftenbände finden Sie in der Regel in den Fachbibliotheken. Wenn Sie sicher sind, dass sich der von Ihnen benötigte Band im Magazin befindet, schalten Sie bitte im Eingabeformular die Jahrgangsprüfung aus."
        when "fehler_jahrgang_falsch"   then "Fehler: Sie haben den Zeitschriftenjahrgang nicht richtig eingegeben! Bitte geben Sie das Jahr vierstellig ein. Bitte beachten Sie dabei: Im Magazin sind nur Jahrgänge bis 1985 untergebracht. Neuere Zeitschriftenbände finden Sie in den Fachbibliotheken."
        else UNDEFINED_ERROR_MESSAGE
      end

      flash.now[:error] = @error_message
      render action: :new
    end
  end

  private

  def setup
    @m1 = params[:m1]
    @k1 = params[:k1]
    @z1 = params[:z1]
    @j1 = params[:j1]
    @b1 = params[:b1]
    @s1 = params[:s1]
    @volume_check = params[:volume_check].present?
  end

end
