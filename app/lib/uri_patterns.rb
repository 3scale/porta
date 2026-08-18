# frozen_string_literal: true

# The uri gem's RFC3986_PARSER does not provide composable string-pattern
# constants. RFC3986 also defines different character sets (e.g. UNRESERVED
# excludes !*'(), QUERY rejects []) which would change validation behavior.
# These RFC2396 patterns are used intentionally to preserve compatibility.
module UriPatterns
  UNRESERVED = URI::RFC2396_REGEXP::PATTERN::UNRESERVED
  ESCAPED    = URI::RFC2396_REGEXP::PATTERN::ESCAPED
  RESERVED   = URI::RFC2396_REGEXP::PATTERN::RESERVED

  HOSTNAME = URI::RFC2396_PARSER.pattern[:HOSTNAME]
  ABS_PATH = URI::RFC2396_PARSER.pattern[:ABS_PATH]
  QUERY    = URI::RFC2396_PARSER.pattern[:QUERY]

  # URL scanner for free-form text (e.g. message bodies).
  HYPERLINK_SCANNER = %r{https?://(?:[^\s()\[\]>]|\([^\s()]*\)|\[[^\s\[\]]*\])+}
end
