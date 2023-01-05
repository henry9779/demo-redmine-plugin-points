class PointSettingsController < ApplicationController
  before_action :set_init_point_setting, only: :index
  before_action :set_users_for_select, only: %i[index create destroy]
  before_action :set_point_setting_list, only: %i[index create destroy]
  before_action :find_point_user, only: :destroy
  before_action :set_pagination_data, only: %i[index create]

  def index; end

  def create
    @point_setting = PointSetting.new(point_setting_params)

    if @point_setting.save
      redirect_to point_settings_path, notice: t('.success')
    else
      flash[:notice] = t('.fail')
      render :index
    end
  end

  def destroy
    @point_setting.destroy
    redirect_to point_settings_path, notice: t('.success', user: @point_setting.user.name)
  end

  private

  def set_users_for_select
    @users = User.active
  end

  def set_init_point_setting
    @point_setting = PointSetting.new
  end

  def set_point_setting_list
    @point_settings = PointSetting.all
  end

  def point_setting_params
    params.require(:point_setting).permit(:user_id)
  end

  def find_point_user
    @point_setting = PointSetting.find_by(id: params[:id])
  end

  def set_pagination_data
    @point_settings_count = @point_settings.count
    @point_settings_page = Redmine::Pagination::Paginator.new @point_settings_count, per_page_option, params['page']
    @_point_settings = @point_settings.offset(@point_settings_page.offset).limit(@point_settings_page.per_page).to_a
  end
end
