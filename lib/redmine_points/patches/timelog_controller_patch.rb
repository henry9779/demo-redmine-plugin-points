module RedminePoints
  module Patches
    module TimelogControllerPatch
      def self.included(base)
        base.include(InstanceMethods)

        base.class_eval do
          helper :points

          before_action :set_point_entries, only: :index
        end
      end

      module InstanceMethods
        def set_point_entries
          retrieve_time_entry_query
          scope = time_entry_scope.preload(issue: %i[project tracker status assigned_to priority])
                                  .preload(:project, :user)

          @point_entries = scope.ids.map(&:to_s)
        end
      end
    end
  end
end

unless TimelogController.included_modules.include?(RedminePoints::Patches::TimelogControllerPatch)
  TimelogController.include(RedminePoints::Patches::TimelogControllerPatch)
end
