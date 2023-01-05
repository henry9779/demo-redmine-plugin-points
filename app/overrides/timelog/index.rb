Deface::Override.new(
  virtual_path: 'timelog/index',
  name: 'add_new_point_link',
  insert_top: 'div.contextual',
  text: "<% if (params_has_date_values? || custom_query_has_date_values?) &&
                allow_setting_point_user? &&
                entries_has_confirmed? &&
                convertible_entries? %>
          <% unless @entries.empty? %>
            <%= form_tag new_point_path, method: :post do %>
              <%= hidden_field_tag 'spent_on', JSON.dump(@filters['spent_on']) %>
              <%= hidden_field_tag 'entries', JSON.dump(@point_entries) %>
              <%= submit_tag l(:label_point_new), id: 'point-icon' %>
            <% end %>
          <% end %>
        <% end %>"
)
