# frozen_string_literal: true

module PatternflyComponentsHelper
  def pf_inline_alert(title, body, variant: nil)
    icon_name = case variant
                when :info then 'info-circle'
                when :success then 'check-circled'
                when :warning, :danger then 'exclamation-triangle'
                else 'bell'
    end

    icon_tag = tag.div class: 'pf-c-alert__icon' do
      tag.i class: "fas fa-fw fa-#{icon_name}", 'aria-hidden': 'true'
    end

    title_tag = tag.p class: 'pf-c-alert__title' do
      title
    end

    body_tag =tag.div class: 'pf-c-alert__description' do
      tag.p body
    end

    tag.div class: "pf-c-alert pf-m-#{variant} pf-m-inline" do
      icon_tag + title_tag + body_tag
    end
  end
end
