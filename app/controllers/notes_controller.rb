# coding: UTF-8
class NotesController < ApplicationController

  before_action :authenticate!
  before_action :get_note, :only => [:edit, :update, :destroy]

  def new
    if params[:resourceid]
      @note = current_user.notes.build :resourceid => params[:resourceid]
    else
      redirect_to root_path
    end
  end

  def create
    note = current_user.notes.build(:resourceid => params[:note][:resourceid], :value => params[:note][:value])

    if note.save
      redirect_to second_last_breadcrumb_url
    else
      redirect_to root_path
    end
  end

  def edit
  end

  def update
    @note.update_attributes(params['note'])
    redirect_to second_last_breadcrumb_url
  end

  def destroy
    @note.destroy
    redirect_back(fallback_location: root_path)
  end

  protected

  def get_note
    @note = current_user.notes.find(params[:id])
    authorize!(:manage, @note)
  end

end
