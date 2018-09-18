module ReferrerFiltersHelper
  def referrer_filter_dom_id(referrer_filter_str)
    # Referrer_filter is a string, NOT a ReferrerFilter object
    escaped = referrer_filter_str.tr('.', '_')
    escaped = h(escaped)

    "referrer_filter_#{escaped}"
  end
end
