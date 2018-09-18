module Provider::SignupsHelper

  def signup_success_data
    session[:success_data].try(:symbolize_keys) || {}
  end

  def phrase_first_name
    if first_name = signup_success_data[:first_name].presence
     "Hi #{first_name}, thank you for signing up."
    else
     "Thank you for signing up."
    end
  end

  def phrase_email
    if email = signup_success_data[:email].presence
      "We have just sent an email to #{inbox_link(email)}".html_safe
    else
      "We have just sent you an email"
    end
  end

  def inbox_link(email)
    case email
    when /@gmail\.com$/
         "#{gmail_inbox_link('your Gmail inbox', email)} at #{h(email)}".html_safe
    else email
    end
  end

  def gmail_inbox_link(text, email)
    link_to(text, 'https://mail.google.com/mail/u/?authuser=' + email, target: '_blank', id: 'gmail-inbox')
  end

  def analytics_credentials
    ThreeScale::Analytics.credentials
  end

  def document_origin
    request.headers['3scale-Origin'] || request.headers['Origin']
  end

  def server_root_url
    uri = URI(root_url)
    uri.path = ''
    uri.to_s
  end

end
