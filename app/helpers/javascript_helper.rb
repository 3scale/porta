module JavascriptHelper
  # Render partial and escape it to form valid javascript string.
  def render_to_js_string(name, options = {})
    ('"' + escape_javascript(render(name, options))  + '"').html_safe
  end
end
