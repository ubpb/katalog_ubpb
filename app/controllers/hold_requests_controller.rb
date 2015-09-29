# coding: UTF-8
class HoldRequestsController < ApplicationController

  before_filter :authenticate!

  def create
    unless Median::Aleph.create_item_hold(current_user.ilsid, params[:record_ils_id], params[:item_id])
      flash[:error] = t('messages.user.create_hold.error')
    end
    redirect_to :back
  end

end
