module RedminePoints
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.include(InstanceMethods)
      end

      module InstanceMethods
        # TimeEntry pointsatuses
        POINT_ID_NIL     = 0
        POINT_ID_PRESENT = 1
      end
    end
  end
end

unless TimeEntry.included_modules.include?(RedminePoints::Patches::TimeEntryPatch)
  TimeEntry.include(RedminePoints::Patches::TimeEntryPatch)
end
