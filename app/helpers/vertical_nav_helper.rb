module VerticalNavHelper
  def vertical_nav_sections
    # - when :personal, :account
    #   = render 'shared/provider/navigation/account/nav',
    #            vertical_nav_item: vertical_nav_item,
    #            layout_secondary_nav: layout_secondary_nav

    # - when :buyers, :finance, :cms, :site, :settings, :audience
    #   = render 'shared/provider/navigation/audience/nav',
    #            vertical_nav_item: vertical_nav_item,
    #            layout_secondary_nav: layout_secondary_nav

    # - when :serviceadmin, :monitoring
    #   = render 'shared/provider/navigation/service/nav',
    #            vertical_nav_item: vertical_nav_item,
    #            layout_secondary_nav: layout_secondary_nav

    case active_menu
    when :personal, :account
      nav.to_json

    when :apis, :applications, :active_docs
      apis_apps_activedocs
    end
  end

  def nav
    sections = []

    if can?(:manage, :partners) || can?(:manage, :settings)
      sections << { title: 'Accounts', items: accounts }
    end

    # - if can?(:manage, :applications)
    #   = render partial: 'shared/provider/navigation/audience/applications',
    #           layout: layout_secondary_nav,
    #           locals: { title: 'Applications',
    #                     icon: 'cubes',
    #                     vertical_nav_item: vertical_nav_item,
    #                     submenu: :applications }

    # - if can?(:see, :finance)
    #   - if can?(:manage, :finance) || can?(:manage, :settings)
    #     = render partial: 'shared/provider/navigation/audience/billing',
    #              layout: layout_secondary_nav,
    #              locals: { title: 'Billing',
    #                        icon: 'credit-card',
    #                        vertical_nav_item: vertical_nav_item,
    #                        submenu: :finance }

    # - if (can?(:manage, :portal) || can?(:manage, :settings) || can?(:manage, :plans)) && !master_on_premises?
    #   = render partial: 'shared/provider/navigation/audience/portal',
    #            layout: layout_secondary_nav,
    #            locals: { title: 'Developer Portal',
    #                      icon: 'sitemap',
    #                      vertical_nav_item: vertical_nav_item,
    #                      submenu: :cms }

    # = render partial: 'shared/provider/navigation/audience/messages',
    #          layout: layout_secondary_nav,
    #          locals: { title: 'Messages',
    #                    icon: 'envelope',
    #                    vertical_nav_item: vertical_nav_item,
    #                    submenu: :messages }

    # - if can?(:manage, :portal) && current_account.forum_enabled?
    #   = render partial: 'shared/provider/navigation/audience/forum',
    #            layout: layout_secondary_nav,
    #            locals: { title: 'Forum',
    #                      icon: 'comments',
    #                      vertical_nav_item: vertical_nav_item,
    #                      submenu: :forum }

    sections
  end

  def accounts
    subItems = []
    if can? :manage, :partners
      subItems << { title: 'Listing', path:  admin_buyers_accounts_path }
    end
    if can?(:manage, :plans) && current_account.settings.account_plans.allowed? && current_account.settings.account_plans_ui_visible?
      subItems << { title: 'Account Plans', path:   admin_buyers_account_plans_path }
    end
    if can?(:manage, :service_contracts) && current_account.settings.service_plans.allowed? && current_account.settings.service_plans_ui_visible?
      subItems << { title: 'Subscriptions', path: admin_buyers_service_contracts_path }
    end

    if can?(:manage, :settings)
      if can? :manage, :partners
        'Settings' # Subtitle, figure out how to render it
      end
      subItems << { title: 'Usage Rules', path:  edit_admin_site_usage_rules_path }
      subItems << { title: 'Fields Definitions', path:   admin_fields_definitions_path }
    end
    subItems
  end

  def apis_apps_activedocs
    if can? :manage, :partners
      items << { title: 'ActiveDocs', path:  admin_api_docs_services_path }
    end

    if can? :manage, :monitoring
      if current_user.multiple_accessible_services?
        items << { title: 'Alerts', path:  admin_alerts_path }
      end
      items << { title: 'Traffic', path:  admin_transactions_path }
    end
  end
end