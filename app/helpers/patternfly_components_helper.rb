# frozen_string_literal: true

module PatternflyComponentsHelper

  def icon_name(variant)
    case variant&.to_sym
    when :danger then 'exclamation-circle'
    when :info then 'info-circle'
    when :success then 'check-circle'
    when :warning then 'exclamation-triangle'
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

  def pf_inline_alert(title, **options)
    plain_class = options[:plain] ? 'pf-m-plain' : ''
    variant = options[:variant]
    variant_class = variant ? "pf-m-#{variant}" : ''
    classes = "pf-c-alert pf-m-inline #{plain_class} #{variant_class}"
    tag.div class: classes do
      icon_tag(variant) + title_tag(title) + description_tag(options[:description])
    end
  end

  # Generates the same HTML as app/javascript/src/utilities/toast.ts#createAlertGroupItem.
  # Duplication is not ideal, but justified since this will be used by rails template for
  # flashes set in controllers.
  def pf_toast_alert(title, **options)
    action_tag = tag.div class: 'pf-c-alert__action' do
      tag.button class: 'pf-c-button pf-m-plain', type: 'button', title: 'Close alert' do
        tag.icon class: 'fas fa-times'
      end
    end

    if (type = options[:type])
      type_class = "pf-m-#{type}"
    end

    classes = "pf-c-alert #{type_class}"
    tag.div class: classes do
      icon_tag(type) + title_tag(title) + action_tag
    end
  end

  # TODO: this action button is used only in app/views/provider/admin/account/users/index.html.slim
  # right now, but could be used in other tables. Eliminate existing repetition by using this helper
  def pf_delete_table_action(url, button_options = {})
    form_attributes = { method: :delete }

    button_class = 'pf-c-button pf-m-link pf-m-danger'

    confirm = button_options.delete(:confirm) || 'It will be permanently delete. Are you sure?'

    button_attributes = { type: :submit,
                          class: button_class.strip,
                          'data-confirm': confirm }.merge(button_options)

    span = tag.span class: 'pf-c-button__icon pf-m-start' do
      tag.i class: "fas fa-trash", 'aria-hidden': 'true'
    end
    label = 'Delete'

    form_tag(url, form_attributes) do
      tag.button(**button_attributes) do
        span + label
      end
    end
  end

  def pf_clipboard_copy(value)
    content_for :javascripts, javascript_packs_with_chunks_tag('clipboard_copy')

    input = tag.input(class: 'pf-c-form-control', value:, readonly: true, type: :text)
    button = tag.button(class: 'pf-c-button pf-m-control', type: :button, aria: { label: 'Copy to clipboard' }) do
               tag.i class: 'fas fa-copy', aria: { hidden: "true" }
             end

    tag.div class: 'pf-c-clipboard-copy' do
      tag.div class: 'pf-c-clipboard-copy__group' do
         input + button
      end
    end
  end

  def pf_nav_item(text, url)
    content_tag 'li', class: 'pf-c-nav__item' do
      link_to_unless_current text, url, class: 'pf-c-nav__link' do |active_text|
        content_tag 'a', active_text, class: 'pf-c-nav__link pf-m-current', 'aria-current': 'page'
      end
    end
  end
end
