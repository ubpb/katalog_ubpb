# coding: utf-8

class SemappController < ApplicationController
  include UrlUtils

  before_filter :add_breadcrumb, :except => [:info]

  # Returns the Sem App name for a given item id
  def info
    url  = "#{Primo.config.aleph_x_service_base_url}/../ub-cgi/ausleiher_von_signatur.pl?#{params[:signature]}"
    result = get_url(url)
    if result.include?('Sem') || result.include?('Tisch') || result.include?('IEMAN')
      render :text => result
    else
      render :text => '–'
    end
  end

end
