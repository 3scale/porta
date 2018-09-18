module Provider::Admin::CMS::EmailTemplatesHelper

  def disable_sending_button
    escaped_snippet = "{% email %}{% do_not_send %}{% endemail %}\n\n".to_json
    js = "$('#cms_template_draft').data('codemirror').setValue( #{escaped_snippet} + $('#cms_template_draft').data('codemirror').getValue());"

    link_to "Disable Sending Snippet", '#',
                     onclick: js,
                     class: 'dangerous-button',
                     title: 'Adds a liquid snippet that prevents the email notification from being send.'
  end
end
