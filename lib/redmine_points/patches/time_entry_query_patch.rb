module RedminePoints
  module Patches
    module TimeEntryQueryPatch
      def self.included(base)
        base.include(InstanceMethods)

        base.class_eval do
          alias_method :available_columns_without_points, :available_columns
          alias_method :available_columns, :available_columns_with_points

          alias_method :initialize_available_filters_without_points, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_points
        end
      end

      class QueryPointColumn < QueryColumn; end

      module InstanceMethods
        def available_columns_with_points
          return @available_columns if @available_columns

          @available_columns = available_columns_without_points
          @available_columns << QueryPointColumn.new(:point_id) if
            PointSetting.exists?(user_id: User.current) || User.current.admin

          @available_columns
        end

        def initialize_available_filters_with_points
          initialize_available_filters_without_points

          if PointSetting.exists?(user_id: User.current) || User.current.admin
            add_available_filter(
              'point_id',
              type: :list,
              name: l(:label_point_plural),
              values: point_values
            )
            add_available_filter(
              'created_on',
              type: :date,
              name: l(:field_created_on)
            )
          end
        end

        def sql_for_point_id_field(field, operator, value)
          case operator
          when '='
            "#{TimeEntry.table_name}.point_id IS NULL" if "#{TimeEntry::POINT_ID_NIL}"
          when '!'
            "#{TimeEntry.table_name}.point_id IS NOT NULL" if "#{TimeEntry::POINT_ID_NIL}"
          end
        end

        private

        def point_values
          [[l(:field_point_id_nil), TimeEntry::POINT_ID_NIL]]
        end
      end
    end
  end
end

unless TimeEntryQuery.included_modules.include?(RedminePoints::Patches::TimeEntryQueryPatch)
  TimeEntryQuery.include(RedminePoints::Patches::TimeEntryQueryPatch)
end
