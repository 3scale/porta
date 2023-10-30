# frozen_string_literal: true

module PatternflyComponentsHelper
  def pf_inline_alert(text, variant: nil)
    icon_name = case variant
                when :info then 'info-circle'
                when :success then 'check-circled'
                when :warning, :danger then 'exclamation-triangle'
                else 'bell'
    end

    icon = tag.div class: 'pf-c-alert__icon' do
      tag.i class: "fas fa-fw fa-#{icon_name}", 'aria-hidden': 'true'
    end

    title = tag.p class: 'pf-c-alert__title' do
      text
    end

    tag.div class: "pf-c-alert pf-m-#{variant} pf-m-inline" do
      icon + title
    end
  end
end
