Deface::Override.new(
  virtual_path: 'timelog/_date_range',
  name: 'add_unconverted_point_tab',
  insert_bottom: 'div.tabs.hide-when-print ul',
  text: "<%= render partial: 'points/tabs' if allow_setting_point_user? %>"
)
