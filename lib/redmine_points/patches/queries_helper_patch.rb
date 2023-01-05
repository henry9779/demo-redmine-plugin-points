require_dependency 'queries_helper'

module RedminePoints
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method :column_value_without_points, :column_value
          alias_method :column_value, :column_value_with_points
        end
      end

      module InstanceMethods
        def column_value_with_points(column, list_object, value)
          if column.name == :point_id && list_object.is_a?(TimeEntry)
            point = Point.find_by(id: value)
            link_to point.subject, point_path(point) if point.present?
          else
            column_value_without_points(column, list_object, value)
          end
        end
      end
    end
  end
end

unless QueriesHelper.included_modules.include?(RedminePoints::Patches::QueriesHelperPatch)
  QueriesHelper.include(RedminePoints::Patches::QueriesHelperPatch)
end
