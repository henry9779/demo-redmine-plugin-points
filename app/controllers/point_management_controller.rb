class PointManagementController < ApplicationController
  before_action :authorize
  before_action :fetch_users, only: :index
  before_action :fetch_users_by_department_cf, only: :index
  before_action :fetch_users_by_district_cf, only: :index
  before_action :fetch_users_by_name, only: :index
  before_action :set_pagination_data, only: :index
  before_action :set_user_point_logs, only: :user_point_log

  helper :users
  include PointsHelper

  def index
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="UserPoints.xlsx"'
        @user_point_columns = user_point_columns
        @user_points = User.includes(:user_point)
                           .pluck(:firstname, :lastname, :value, :remark)
      }
    end
  end

  def user_points
    render_defaults(update_users_points, tab: :users)
  end

  def user_point_log; end

  private

  def authorize
    deny_access unless allow_setting_point_user?
  end

  def fetch_users
    @status = params[:status] || 1
    @users = User.logged.status(@status)
  end

  def render_defaults(errors, url_opts = {})
    render_points(
      errors,
      point_management_index_path(url_opts)
    )
  end

  def render_points(errors, url)
    if errors.present?
      flash[:notice] = l(:notice_successful_update)
      redirect_to url
    else
      render :index, notice: l(:notice_successful_update)
    end
  end

  def user_points_params
    params[:user_points]&.to_unsafe_h || {}
  end

  def update_users_points
    user_points_params.each_value do |user_points|
      user_points.each do |user_id, point|
        user_point = UserPoint.find_by(user_id: user_id)
        if user_point.present?
          update_user_point!(user_point, point[:value], point[:remark])
        elsif point[:value].present? || point[:remark].present?
          create_user_point!(user_id, point[:value], point[:remark])
        end
      end
    end
  end

  def update_user_point!(user_point, value, remark)
    if value.present? || remark.present?
      user_point_log = user_point.init_log(User.current)
      user_point_log.add_point_detail(user_point.user, user_point.value, value) if user_point.value.to_d != value.to_d
      user_point_log.add_remark_detail(user_point.user, user_point.remark, remark) if user_point.remark != remark
      user_point_log.save

      user_point.update(value: value, remark: remark)
    else
      true
    end
  end

  def create_user_point!(user_id, value, remark)
    if value.present? || remark.present?
      user = User.find_by(id: user_id)
      user_point = UserPoint.create(user: user, value: value, remark: remark)

      user_point_log = user_point.init_log(User.current)
      user_point_log.add_point_detail(user, nil, value) if value.present?
      user_point_log.add_remark_detail(user, nil, remark) if remark.present?
      user_point_log.save
    else
      true
    end
  end

  def fetch_users_by_department_cf
    return unless params[:dept].present?

    dept_cf = CustomField.find_by(type: 'UserCustomField', name: '单位')
    @users = @users.select { |user| user.custom_field_value(dept_cf).include? params[:dept] }
    @users = User.where(id: @users.map(&:id))
  end

  def fetch_users_by_district_cf
    return unless params[:dist].present?

    dist_cf = CustomField.find_by(type: 'UserCustomField', name: '区域')
    @users = @users.select { |user| user.custom_field_value(dist_cf).eql? params[:dist] }
    @users = User.where(id: @users.map(&:id))
  end

  def fetch_users_by_name
    query_name = params[:name]
    return unless query_name.present?

    converter = Tradsim::Converter.new(query_name)
    sim_name = converter.to_sim
    sim_name_users = @users.like(sim_name)
    trad_name = converter.to_trad
    trad_name_users = @users.like(trad_name)
    ids = (sim_name_users.ids + trad_name_users.ids).uniq

    @users = @users.where(id: ids)
  end

  def set_pagination_data
    @users_count = @users.count
    @users_page = Redmine::Pagination::Paginator.new @users_count, per_page_option, params['page']
    @_users = @users.offset(@users_page.offset).limit(@users_page.per_page).to_a
  end

  def set_user_point_logs
    user_point = UserPoint.find_by(user_id: params[:format])
    @user = User.find_by(id: params[:format])
    @user_point_logs = user_point.logs
  end

  def user_point_columns
    [
      '#',
      l(:field_firstname),
      l(:field_lastname),
      l('activerecord.attributes.user_point.value'),
      l('activerecord.attributes.user_point.remark'),
      l(:field_district),
      l(:field_department)
    ]
  end
end
