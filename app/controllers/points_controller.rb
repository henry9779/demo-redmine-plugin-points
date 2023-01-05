class PointsController < ApplicationController
  before_action :authorize
  before_action :set_entries, only: :new
  before_action :find_point, only: %i[show edit update destroy]
  before_action :find_points, only: :index
  before_action :find_point_logs, only: %i[show update]

  helper :issues
  helper :point_lines
  include PointsHelper

  def index
    @point_count = @points.count
    @points_page = Redmine::Pagination::Paginator.new @point_count, per_page_option, params['page']
    @_points = @points.offset(@points_page.offset).limit(@points_page.per_page).to_a
  end

  def show
    @point_lines = @point.lines || []

    respond_to do |format|
      format.html {}
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="Points.xlsx"'
        @lines = @point_lines.without_reject
        @line_columns = line_export_columns
      }
    end
  end

  def new
    @point = Point.new
    @point.point_date = Date.today
    @point.author = User.current
    @point.lines_from_time_entries(@entries)
    set_date
  end

  def create
    @point = Point.new
    @point.safe_attributes = params[:point]

    if @point.save
      @point.lines.each(&:save)

      if @point.status_id_sync? && @point.lines.all?(&:status_id_pending?)
        service = WadeApi::CreatPoint.new(@point)
        service.perform
      end

      flash[:notice] = t('.success')
      respond_to do |format|
        format.html { redirect_to action: 'show', id: @point }
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    @point.safe_attributes = params[:point]

    if @point.save
      @point.lines.each(&:save)

      if @point.status_id_sync? && @point.lines.all?(&:status_id_pending?)
        service = WadeApi::CreatPoint.new(@point)
        service.perform
      end

      redirect_to points_path, notice: t('.success')
    else
      render :edit
    end
  end

  def destroy
    @point.destroy
    redirect_to points_path, notice: t('.success')
  end

  private

  def authorize
    deny_access unless allow_setting_point_user?
  end

  def set_entries
    entry_ids = JSON.parse(params[:entries])
    entries = TimeEntry.where(id: entry_ids)
    convertible_entries = entries.select { |entry| entry.point_id.nil? }
    # 若篩選出來的工時 若 已轉換 則跳出 跳出提醒
    if convertible_entries.blank?
      flash[:error] = t(:error_entries_unconfirmed)
      redirect_to :back
    else
      convertible_entry_ids = convertible_entries.pluck(:id)
      @entries = TimeEntry.where(id: convertible_entry_ids)
    end
  end

  def set_date
    spent_on = JSON.parse(params[:spent_on])
    date_values = spent_on['values']

    @point.start_date = date_values.first
    @point.end_date = date_values.last
  end

  def find_point
    @point = Point.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_points
    @points = Point.all

    if params[:start_date].present? && params[:end_date].present?
      date_range = (params[:start_date]..params[:end_date])
      @points = @points.where(start_date: date_range, end_date: date_range)
    end

    @points = @points.where(subject: params[:subject]) if params[:subject].present?
    @points = @points.where(status_id: params[:status_id]) if params[:status_id].present?
    @points = @points.where(author_id: params[:author_id]) if params[:author_id].present?
  end

  def find_point_logs
    @point_logs = PointLog.where(point_id: @point)
  end

  def line_export_columns
    ['#', l(:field_point_line_status_id), l(:field_point_line_user_id), l(:field_point_line_user_area),
     l(:field_point_line_user_unit), l(:field_point_line_project_id), l(:field_point_line_purple_no),
     l(:field_point_line_total_entries), l(:field_point_line_value), l(:field_point_line_convert_value),
     l(:field_point_line_carry_value), l(:field_point_line_description)]
  end
end
