module TableHelper
  # Renders table rows with two columns: name and value, filled with attributes of
  # the given record.
  #
  # == Example
  #
  #   table_rows_for(user, :username, :email)
  #
  # renders:
  #
  #   <tr>
  #     <th>Username</th>
  #     <td>bob</td>
  #   </tr>
  #   <tr>
  #     <th>Email</th>
  #     <td>bob@example.com</td>
  #   </tr>
  #
  def table_rows_for(record, *attributes)
    content = ''

    attributes.each do |attribute|
      name  = record.class.human_attribute_name(attribute)
      value = record.send(attribute).to_s

      content << content_tag(:tr, content_tag(:th, h(name)) +
                                  content_tag(:td, h(value)))
    end

    content
  end
end
