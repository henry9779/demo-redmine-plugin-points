Rails.configuration.to_prepare do
  require 'redmine_points/patches/user_patch'
  require 'redmine_points/patches/timelog_controller_patch'
  require 'redmine_points/patches/time_entry_query_patch'
  require 'redmine_points/patches/queries_helper_patch'
  require 'redmine_points/patches/time_entry_patch'
end
