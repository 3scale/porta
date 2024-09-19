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

  def description_tag(description)
    return unless description

    tag.div class: 'pf-c-alert__description' do
      tag.p description
    end
  end

  def pf_inline_alert(title, variant: nil, description: nil, plain: false)
    plain_class = plain ? 'pf-m-plain' : ''
    variant_class = variant ? "pf-m-#{variant}" : ''
    classes = "pf-c-alert pf-m-inline #{plain_class} #{variant_class}"
    tag.div class: classes do
      icon_tag(variant) + title_tag(title) + description_tag(description)
    end
  end
end
