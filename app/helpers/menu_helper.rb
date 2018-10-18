module MenuHelper
  def main_menu_item(id, label, path, options = {})
    fake_active = respond_to?(:active_upgrade_notice) && (id == active_upgrade_notice)
    options[:active] = (id == active_menu) || fake_active
    menu_item(label, path, options)
  end

  def submenu_item(label, path, options = {})
    label = options[:label] || label

    options[:active] = active_menu?(:submenu, label) || current_page?(path)
    menu_item(label, path, options)
  end

  def menu_item(label, path, options = {})
    container_options = options.delete(:container_options) || {}

    if options.delete(:active)
      container_options[:class] = join_dom_classes(container_options[:class], 'active')
    end

    link = switch_link(label, path, options)
    return unless link

    content_tag :li, link, container_options
  end

  def menu_link(level, title, path, options = {}, li_options = {}, &block)
    current_title = options.delete(:title) || title
    if active_menu?(level, current_title) || current_page?(path)
      li_options[:class] = :active
    end

    # humanize only if it is NOT a string, otherwise it would destroy capitalization
    title = title.to_s.humanize.camelize unless title.is_a?(String)

    link = switch_link(title, path, options)
    return unless link

    link << capture(&block) if block

    content_tag(:li, link, li_options)
  end

  def sidebar_link(*args, &block)
    menu_link :sidebar, *args, &block
  end

  def provider_submenu_link(*args, &block)
    menu_link :submenu, *args, &block
  end

  def switch_link(name, path, options = {})
    if switch = options.delete(:switch)
      link_to_switch_or_upgrade(name, options, path, switch)
    else
      link_to(name, path, options)
    end
  end

  def link_to_switch_or_upgrade(name, options, path, switch)
    return if forcibly_denied_switch?(switch)

    if can?(:admin, switch)
      upgrade = options.delete(:upgrade_notice)

      if can?(:see, switch)
        link_to(name, path, options)
      elsif upgrade
        options[:class].gsub!(/(?: fancybox |^fancybox$)/, ' ') if options[:class]
        upgrade_notice_link(switch, name, options)
      end

    end
  end

  def upgrade_notice_link(switch, name, options = {})
    options = { class: 'upgrade-notice' }.merge(options)
    link_to(name, admin_upgrade_notice_path(switch), options)
  end

  def forcibly_denied_switch?(switch)
    account = current_account.provider? ? current_account : current_account.provider_account
    account.settings.public_send(switch).is_a?(Settings::SwitchDenied)
  end

  def api_selector_services
    @api_selector_services ||= site_account.provider? && logged_in? ? current_user.accessible_services.includes(:account) : Service.none
  end

  def audience_link
    if can?(:manage, :partners)
      admin_buyers_accounts_path
    elsif can?(:manage, :finance)
      admin_finance_root_path
    elsif can?(:manage, :portal)
      provider_admin_cms_templates_path
    elsif can?(:manage, :settings)
      edit_admin_site_usage_rules_path
    end
  end

end
