# frozen_string_literal: true

module MenuHelper # rubocop:disable Metrics/ModuleLength
  include ApplicationHelper

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

  def audience_link
    @audience_link ||= if can?(:manage, :partners)
                         admin_buyers_accounts_path
                       elsif can?(:manage, :finance)
                         admin_finance_root_path
                       elsif can?(:manage, :portal)
                         provider_admin_cms_templates_path
                       elsif can?(:manage, :settings)
                         edit_admin_site_usage_rules_path
                       end
  end

  def settings_link
    can?(:manage, current_account) ? provider_admin_account_path : edit_provider_admin_user_personal_details_path
  end

  def current_api
    @backend_api || @service
  end

  def vertical_nav_hidden?(menu = active_menu)
    %i[dashboard products backend_apis quickstarts].include?(menu)
  end

  def masthead_props
    {
      brandHref: provider_admin_dashboard_path,
      contextSelectorProps: context_selector_props.as_json,
      currentAccount: current_account.name,
      currentUser: current_user.decorate.display_name,
      documentationMenuItems: documentation_items.as_json,
      impersonating: current_user.impersonation_admin? && !current_account.master?,
      signOutHref: provider_logout_path,
      verticalNavHidden: vertical_nav_hidden?
    }
  end

  def context_selector_props
    title, icon = active_title_and_icon
    access_to_service_admin_sections = current_user.access_to_service_admin_sections?

    menu_items = [{ title: 'Dashboard',        href: provider_admin_dashboard_path,    icon: :home,     disabled: false }]
    menu_items << { title: 'Audience',         href: audience_link,                    icon: :bullseye, disabled: false } if audience_link.present?
    menu_items << { title: 'Products',         href: admin_services_path,              icon: :cubes,    disabled: false } if access_to_service_admin_sections
    menu_items << { title: 'Backends',         href: provider_admin_backend_apis_path, icon: :cube,     disabled: false } if can?(:read, BackendApiConfig) || can?(:manage, :monitoring)
    menu_items << { title: 'Account Settings', href: settings_link,                    icon: :cog,      disabled: false }

    {
      toggle: { title: title, icon: icon },
      menuItems: menu_items
    }
  end

  def active_title_and_icon
    case active_menu
    when :dashboard
      %w[Dashboard home]
    when :personal, :account, :active_docs
      ['Account Settings', 'cog']
    when :audience, :buyers, :finance, :cms, :site, :settings, :apis, :applications
      %w[Audience bullseye]
    when :serviceadmin, :monitoring, :products
      %w[Products cubes]
    when :backend_api, :backend_apis
      %w[Backends cube]
    when :quickstarts
      ['--', '']
    end
  end

  def documentation_items
    items = [
      { title: 'Customer Portal', href: '//access.redhat.com/products/red-hat-3scale', icon: :'external-link-alt', target: '_blank'},
      { title: '3scale API Docs', href: provider_admin_api_docs_path, icon: :'puzzle-piece' },
      { title: 'Liquid Reference', href: provider_admin_liquid_docs_path, icon: :code }
    ]

    if ThreeScale.saas?
      items.push(
        { title: "What's new?", href: '//access.redhat.com/articles/3107441#newfeaturesenhancements', icon: :leaf, target: '_blank' }
      )
    end

    if Features::QuickstartsConfig.enabled?
      items.push(
        { title: 'Quick starts', href: provider_admin_quickstarts_path, icon: :book }
      )
    end

    items
  end
end
