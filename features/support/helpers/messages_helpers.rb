module MessagesHelpers
  def find_delete_button_in_row(label, *cells)
    forms = find(:xpath, selector_for_table_row_with_cells(*cells)).all('td form')
    forms = forms.select do |form|
      form[:method] == 'post' && form.has_css?('input[name = "_method"][value = "delete"]')
    end

    forms.first.find_button(label).tap do |button|
      assert_not_nil button, %(No "#{label}" button found)
    end
  end
end
