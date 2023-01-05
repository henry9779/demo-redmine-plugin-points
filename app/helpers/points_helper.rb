module PointsHelper
  def options_for_status(point)
    valid_keys = ['sync'].unshift(point.status_id)

    options_for_select(valid_keys.map { |k| [t("point_status.#{k}"), k] },
                       point.status_id)
  end

  def link_to_show_point(point)
    link_to point.date_range, point_path(point)
  end

  def start_date_options_for_select
    params[:start_date] || nil
  end

  def end_date_options_for_select
    params[:end_date] || nil
  end

  def query_subject_tag
    content_tag(:span) do
      concat label_tag 'subject', l(:field_point_subject), class: 'subject'
      concat select_tag 'subject', subject_options_for_select, multiple: true, class: 'query_select'
    end
  end

  def subject_options_for_select
    options_for_select(@points.collect { |point| [point.subject, point.subject] }.uniq, params[:subject])
  end

  def query_status_tag
    content_tag(:span) do
      concat label_tag 'status_id', l(:field_point_status_id), class: 'status_id'
      concat select_tag 'status_id', status_options_for_select, multiple: true, class: 'query_select'
    end
  end

  def status_options_for_select
    options_for_select(Point.status_ids.map { |k, v| [l("point_status.#{k}"), v] }, params[:status_id])
  end

  def query_author_tag
    content_tag(:span) do
      concat label_tag 'author_id', l(:field_point_author_id), class: 'author_id'
      concat select_tag 'author_id', author_options_for_select, multiple: true, class: 'query_select'
    end
  end

  def author_options_for_select
    options_for_select(@points.collect { |point| [point.author, point.author.id] }.uniq, params[:author_id])
  end

  def params_has_date_values?
    if params[:v]&.key?(:spent_on)
      params[:v][:spent_on].size == 2
    else
      false
    end
  end

  def custom_query_has_date_values?
    return false if params[:query_id].blank?

    query = Query.find(params[:query_id])
    if query.filters.key?('spent_on')
      query.filters['spent_on'][:values].size == 2
    end
  end

  def allow_setting_point_user?(user = User.current)
    PointSetting.exists?(user_id: user) || user.admin
  end

  def entries_has_confirmed?
    cf_id = CustomField.find_by(type: 'TimeEntryCustomField', name: '確認工時').try(:id)
    confirmed_entries = @entries.all? { |entry| entry.custom_field_value(cf_id) == '1' }
    confirmed_entries.present?
  end

  def convertible_entries?
    convertible_entries = @entries.all? { |entry| entry.point_id.nil? }
    convertible_entries.present?
  end

  def link_to_remove_point_fields(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name,
                                                 "remove_point_fields(this, #{options[:idx]})",
                                                 options)
  end

  def link_to_edit_line_entries(f)
    link_to f.object.total_entries, point_line_edit_entries_path(f.object), remote: true
  end

  def point_details_to_strings(details, no_html = false, options = {})
    options[:only_path] = (options[:only_path] != false)
    strings = []

    details.each do |detail|
      id_name = "line_#{detail.log_detail_id}" if detail.log_detail_id?
      strings << content_tag('li',
                             point_show_detail(detail, no_html, options),
                             class: 'lines',
                             id: id_name)
    end
    strings
  end

  def point_show_detail(detail, no_html = false, options = {})
    multiple = false

    case detail.property
    when 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, '')
      label = l(('field_' + field).to_sym)
      case detail.prop_key
      when 'status_id'
        value = convert_to_point_line_status('point_line_status', detail.value)
        old_value = convert_to_point_line_status('point_line_status', detail.old_value)
      when 'point_status', 'point_close'
        value = convert_to_point_status('point_status', detail.value)
        old_value = convert_to_point_status('point_status', detail.old_value)
      end
    end

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value

    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag('i', h(old_value)) if detail.old_value
      if detail.old_value && detail.value.blank? && detail.property != 'relation'
        old_value = content_tag('del', old_value)
      end
    end

    if detail.value.present?
      case detail.property
      when 'attr', 'cf'
        if detail.prop_key.eql? 'point_status'
          tags = ''.html_safe
          tags << l(:text_journal_changed, label: label, old: old_value, new: value).html_safe
          point_log = detail.point_log
          tags << content_tag('li', textilizable(point_log, :note)) if point_log.note.present?
          tags
        elsif detail.prop_key.eql? 'point_close'
          point_finish_time = detail.point_log.point.closed_on.strftime('%Y-%m-%d %H:%M:%S')
          l(:text_point_finish_and_set, time: point_finish_time, label: l(:field_point_status), value: value).html_safe
        elsif detail.prop_key.eql? 'api_error'
          l(:text_point_api_error, value: value).html_safe
        elsif detail.old_value.present?
          l(:text_journal_changed, label: label, old: old_value, new: value).html_safe
        elsif multiple
          l(:text_journal_added, label: label, value: value).html_safe
        else
          l(:text_journal_set_to, label: label, value: value).html_safe
        end
      end
    else
      l(:text_journal_deleted, label: label, old: old_value).html_safe
    end
  end

  def convert_to_point_line_status(field, id)
    return nil if id.blank?

    status_id = id.to_i
    status = PointLine.status_ids.key(status_id)
    status_str = field << '.' << status
    l(status_str)
  end

  def convert_to_point_status(field, id)
    return nil if id.blank?

    status_id = id.to_i
    status = Point.status_ids.key(status_id)
    status_str = field << '.' << status
    l(status_str)
  end

  def unconverted_entries_url(params = nil)
    # 抓確認工時自訂欄位 並將 確認工時為是 的 篩選 加到下面的 JSON
    check_entry_cf = CustomField.find_by(type: 'TimeEntryCustomField', name: '確認工時')
    cf_f = check_entry_cf.css_classes
    cf_op = Hash[cf_f, '=']
    cf_v = Hash[cf_f, ['1']]
    prev_month_start = DateTime.now.prev_month.beginning_of_month.strftime('%Y-%m-%d')
    prev_month_end = DateTime.now.prev_month.end_of_month.strftime('%Y-%m-%d')
    prev_month = [prev_month_start, prev_month_end]
    default_columns = %w[spent_on user activity issue comments hours]
    columns = params.try(:[], 'c').present? ? params['c'] : default_columns

    {
      controller: 'timelog',
      action: 'index',
      set_filter: '1',
      sort: 'id:desc',
      f: %w[spent_on point_id] << cf_f,
      op: { spent_on: '><', point_id: '=' }.merge(cf_op),
      v: { spent_on: prev_month, point_id: ['0'] }.merge(cf_v),
      c: columns,
      t: ['hours']
    }
  end

  def converted_entries_url(params = nil)
    default_columns = %w[spent_on user activity issue comments hours]
    columns = params.try(:[], 'c').present? ? params['c'] : default_columns

    {
      controller: 'timelog',
      action: 'index',
      set_filter: '1',
      sort: 'id:desc',
      f: %w[spent_on point_id],
      op: { spent_on: '*', point_id: '!' },
      v: { point_id: ['0'] },
      c: columns,
      t: ['hours']
    }
  end

  def point_id_operator(query)
    filters = query.filters
    filters['point_id'][:operator].first if filters.key?('point_id')
  end

  def selected_unconverted_entries(query)
    'selected' if point_id_operator(query) == '='
  end

  def selected_converted_entries(query)
    'selected' if point_id_operator(query) == '!'
  end
end
