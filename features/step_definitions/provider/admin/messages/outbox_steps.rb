# frozen_string_literal: true

When "(they )delete the message with subject {string}" do |subject|
  message = Message.find_by!(subject: subject)
  find('tr', id: dom_id(message)).click_button('Delete')
end
