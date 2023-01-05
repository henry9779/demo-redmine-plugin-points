module RedminPoints
  module Patches
    module UserPatch
      def self.included(base)
        base.include(InstanceMethods)

        base.class_eval do
          has_one :user_point
        end
      end

      module InstanceMethods
        def unit_cf_value
          cf_id = CustomField.find_by(type: 'UserCustomField', name: '单位').try(:id)
          custom_field_value(cf_id).join(',')
        end

        def area_cf_value
          cf_id = CustomField.find_by(type: 'UserCustomField', name: '区域').try(:id)
          custom_field_value(cf_id)
        end
      end
    end
  end
end

unless User.included_modules.include?(RedminPoints::Patches::UserPatch)
  User.include(RedminPoints::Patches::UserPatch)
end
