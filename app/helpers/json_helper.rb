module JsonHelper


  def json(string)
    json_escape(string.to_json).html_safe
  end

  # Backported from Rails 4.2

  class JsonEscapingError < StandardError; end

  JSON_ESCAPE_REGEXP = /[\u2028\u2029&><]/u
  JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003e', '<' => '\u003c', "\u2028" => '\u2028', "\u2029" => '\u2029' }

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape

end
