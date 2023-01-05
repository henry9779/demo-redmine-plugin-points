class PointLinesController < ApplicationController
  before_action :find_point_line, only: :destroy
  before_action :find_point_line_from_entries, only: %i[edit_entries update_entries]

  def destroy
    @point_line.destroy
  end

  def edit_entries
    @time_entries = @point_line.retrieve_time_entries
    respond_to do |format|
      format.js
    end
  end

  def update_entries
    unpdated_entries = @point_line.time_entry_ids
    @point_line.safe_attributes = params[:point_line]
    updated_entries = @point_line.time_entry_ids
    destroy_entry_ids = unpdated_entries - updated_entries

    if destroy_entry_ids.any?
      empty_destroy_entry_point_id(destroy_entry_ids)
      @point_line.update_values
    end

    respond_to do |format|
      format.js { @destroy_entries = destroy_entry_ids }
    end
  end

  private

  def find_point_line
    @point_line = PointLine.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_point_line_from_entries
    @point_line = PointLine.find(params[:point_line_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def empty_destroy_entry_point_id(destroy_entry_ids)
    destory_entries = TimeEntry.where(id: destroy_entry_ids)
    destory_entries.update_all(point_id: nil)
  end
end
