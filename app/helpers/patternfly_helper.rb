# frozen_string_literal: true

module PatternflyHelper
  def pf_button_in_title(label, href)
    link_to label, href, class: %w[pf-c-button pf-m-primary pf-c-button__in-title]
  end
end
