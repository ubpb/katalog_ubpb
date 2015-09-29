# coding: utf-8

class TicketsController < ApplicationController

  SUBDOMAIN_NAME = 'ubpb'
  API_KEY        = 'rjHCKfseeKApdOSlEqqq5w'
  API_SECRET     = 'YvCsQCwVzeCM4b7sEB30MhQpkI8KNwYAt81geRFiJk'

  def new
    @ticket = Ticket.new
    @ticket.email = current_user.email if current_user && current_user.email.present?
  end

  def create
    @ticket = Ticket.new(params[:ticket])

    if @ticket.valid?
      client = UserVoice::Client.new(SUBDOMAIN_NAME, API_KEY, API_SECRET)
      client.post("/api/v1/tickets.json", {
        email: @ticket.email,
        ticket: {
          subject: @ticket.subject,
          message: @ticket.message
        }
      })

      flash[:success] = "Vielen Dank für Ihre Nachricht. Wir werden uns in Kürze mit Ihnen in Verbindung setzen."
      redirect_to root_path
    else
      render :new
    end
  end

end
