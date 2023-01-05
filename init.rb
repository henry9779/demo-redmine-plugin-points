Redmine::Plugin.register :redmine_points do
  name ' Redmine Points'
  author 'Purplevine IP'
  description 'This is a plugin for calculate employee salaries'
  version '0.0.1'
  url 'http://gitlab.epurplevineip.com/Henry/redmine_points'
  author_url 'http://gitlab.epurplevineip.com/Henry/redmine_points'

  menu :top_menu,
       :points,
       { controller: :points, action: :index },
       caption: :label_point_plural,
       if: proc { User.current.admin? || PointSetting.find_by(user_id: User.current).present? }

  menu :admin_menu,
       :point_settings,
       { controller: :point_settings, action: :index },
       caption: :label_point_settings,
       html: { class: 'icon icon-settings settings' }

  Rails.application.paths['app/overrides'] ||= []
  Rails.application.paths['app/overrides'] << File.expand_path('../app/overrides', __FILE__)
end
