module PointSettingsHelper
  def options_for_user
    options_for_select(@users.map { |user| [user.name, user.id] })
  end
end
