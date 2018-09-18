$(document).ready ->
  $("#liquid-settings").submit (e) ->
    if $('#settings_cms_escape_draft_html').is(':checked') && $('#settings_cms_escape_published_html').is(':checked')
      message = """
        Are you sure you want to escape all liquid drops output?

        Please make sure that your developer portal works fine before
        continuing. Enabling the XSS protection is a one-way settings
        and can only be reverted by support.
      """

      unless (confirm(message))
        e.preventDefault()
