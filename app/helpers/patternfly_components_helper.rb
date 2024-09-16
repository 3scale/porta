# frozen_string_literal: true

module PatternflyComponentsHelper

  def icon_name(variant)
    case variant
    when :info then 'info-circle'
    when :success then 'check-circled'
    when :warning, :danger then 'exclamation-triangle'
    else 'bell'
    end
  end

  def icon_tag(variant)
    tag.div class: 'pf-c-alert__icon' do
      tag.i class: "fas fa-fw fa-#{icon_name(variant)}", 'aria-hidden': 'true'
    end
  end

  def title_tag(title)
    tag.div class: 'pf-c-alert__title' do
      tag.p title
    end
  end

  def body_tag(body)
    tag.div class: 'pf-c-alert__description' do
      tag.p body
    end
  end

  def pf_inline_alert(title, body, variant: nil)
    tag.div class: "pf-c-alert pf-m-#{variant} pf-m-inline" do
      icon_tag(variant) + title_tag(title) + body_tag(body)
    end
  end

  def pf_inline_alert_plain(title, variant: nil)
    tag.div class: "pf-c-alert pf-m-#{variant} pf-m-inline pf-m-plain" do
      icon_tag(variant) + title_tag(title)
    end
  end
end
