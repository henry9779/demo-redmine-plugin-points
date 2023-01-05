module PointManagementHelper
  def user_dept_options_for_select
    dept_cf = CustomField.find_by(type: 'UserCustomField', name: '单位')
    dept_values = dept_cf.possible_values.unshift('')

    options_for_select(dept_values.map { |val| [val, val] }, params[:dept])
  end

  def user_dist_options_for_select
    dist_cf = CustomField.find_by(type: 'UserCustomField', name: '区域')
    dist_values = dist_cf.possible_values.unshift('')

    options_for_select(dist_values.map { |val| [val, val] }, params[:dist])
  end

  def user_point_to_strings(details)
    strings = []

    details.each do |detail|
      strings << content_tag('li', user_point_show_detail(detail), class: 'lines')
    end

    strings
  end

  def user_point_show_detail(detail)
    user = detail.user
    prop = detail.property
    old_value = detail.old_value
    value = detail.value
    value = l(:text_user_point_value_nil) if value.blank?
    value = content_tag('i', h(value))

    if old_value.nil?
      l("text_user_point_new_#{prop}", user: user, value: value).html_safe
    else
      old_value = l(:text_user_point_value_nil) if old_value.blank?
      old_value = content_tag('i', h(old_value))
      l("text_user_point_update_#{prop}", user: user, old: old_value, value: value).html_safe
    end
  end
end
