module PointLinesHelper
  def link_to_remove_entry_lines(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name,
                                                 'remove_entry_lines(this)',
                                                 options)
  end

  def link_to_remove_entry_lines_new_record(name, options = {})
    link_to_function(name, 'remove_entry_lines_new_record(this)', options)
  end
end
