require 'sprockets'
require 'compass-rails'
require 'sass'

class SimpleLayout

  attr_reader :provider

  def initialize(provider)
    @provider = provider
  end

  def import_authentication
    github = provider.authentication_providers.build_kind(kind: :github, published: true)
    github.save
  end

  def import_pages!
    main_layout = setup_main_layout!

    provider.pages.find_by_path('/') ||
      provider.pages.build(title: 'Homepage',
                           path: '/',
                           liquid_enabled: true,
                           section: root,
                           layout: main_layout,
                           draft: DeveloperPortal::VIEW_PATH.join('index.html.liquid').read,
                           content_type: 'text/html'
                          ).publish!

    provider.pages.find_by_path('/docs') ||
      provider.pages.build(title: 'Documentation',
                           path: '/docs',
                           liquid_enabled: true,
                           section: root,
                           layout: main_layout,
                           draft: DeveloperPortal::VIEW_PATH.join('docs.html.liquid').read,
                           content_type: 'text/html'
                          ).publish!

    provider.partials.build(system_name: 'analytics',
                            draft: DeveloperPortal::VIEW_PATH.join('_analytics.html.liquid').read).publish!
  end

  def import_js_and_css!
    main_layout = provider.layouts.find_by_system_name("main_layout")

    javascripts = Pathname.glob(DeveloperPortal::VIEW_PATH.join('javascripts/*.js'))
    styles = Pathname.glob(DeveloperPortal::VIEW_PATH.join('css/*.css'))

    [ javascripts, styles ].flatten.each do |file|
      content = file.read.strip_heredoc

      case file.extname[1..-1]
      when 'js' then
        content_type = Mime[:js].to_s
        section = find_or_create_section('javascripts', '/javascripts')
      when 'css' then
        content_type = Mime[:css].to_s
        section = find_or_create_section('css', '/css')
      else
        content_type = Mime::HTML.to_s
        section = root
      end

      page = provider.pages.build(title: file.basename.to_s,
                                  path: file.to_s.gsub(DeveloperPortal::VIEW_PATH.to_s,''),
                                  draft: content,
                                  section: section,
                                  layout: content_type == 'text/html' ? main_layout : nil,
                                  content_type: content_type)
      page.publish!
    end
  end

  def import_images!
    images = Pathname.glob(DeveloperPortal::VIEW_PATH.join('images/*.{jpg,png,gif}'))
    icons = Pathname.glob(DeveloperPortal::VIEW_PATH.join('favicon.ico'))
    images_section = find_or_create_section('images', '/images')

    [ images, icons ].flatten.each do |path|
      provider.files.create!(attachment: File.new(path), path: path.to_s.gsub(DeveloperPortal::VIEW_PATH.to_s,''), section: images_section)
    end
  end

  def import! # _all
    provider.class.transaction do
      import_authentication if AuthenticationProvider.branded_available?

      setup_main_layout!
      setup_error_layout!

      import_pages!
      import_js_and_css!
      import_images!

      create_builtin_pages_and_partials!
      import_static_pages!
    end
  end

  def import_static_pages!
    builtin_static_pages.each do |layout|
      unless provider.builtin_static_pages.where(system_name: layout[:system_name]).exists?
        build_builtin_static_page(layout).save!
      end
    end
  end

  def setup_error_layout!
    if error_layout= provider.layouts.find_by_system_name("error")
      update_error_layout!(error_layout)
    else
      create_error_layout!
    end
  end

  def create_builtin_pages_and_partials!
    p = provider.builtin_pages

    # Shared
    create_builtin_partial!('field')
    create_builtin_partial!('shared/pagination')
    create_builtin_partial!('shared/swagger_ui')
    create_builtin_partial!('submenu')
    create_builtin_partial!('menu_item')
    create_builtin_partial!('users_menu')

    # Dashboard
    p.find_or_create! 'dashboards/show', 'Dashboard', root

    # Password
    password_section = find_or_create_section('Password', '/password')
    p.find_or_create! 'password/new', 'Reset password', password_section
    p.find_or_create! 'password/show', 'Reset password form', password_section

    # Login
    login_section = find_or_create_section('Login', '/login')
    p.find_or_create! 'login/new', 'Login', login_section
    create_builtin_partial!('login/sso')

    # Signup
    signup = find_or_create_section('Signup', '/signup')
    p.find_or_create! 'signup/show', 'Signup Form', signup
    p.find_or_create! 'signup/success', 'Signup Success', signup
    create_builtin_partial!('signup/cas')

    # Messages
    create_builtin_partial!('messages/menu')
    messages = find_or_create_section('Messages', '/messages')
    outbox = find_or_create_section('Outbox', '/messages/outbox', parent: messages)
    inbox = find_or_create_section('Inbox', '/messages/inbox', parent: messages)
    trash = find_or_create_section('Trash', '/messages/trash', parent: messages)
    p.find_or_create! 'messages/outbox/index', 'Outbox', outbox
    p.find_or_create! 'messages/outbox/show', 'View Message', outbox
    p.find_or_create! 'messages/outbox/new', 'Compose', outbox
    p.find_or_create! 'messages/inbox/index', 'Inbox', inbox
    p.find_or_create! 'messages/inbox/show', 'View Message', inbox
    p.find_or_create! 'messages/trash/index', 'Trash', trash
    p.find_or_create! 'messages/trash/show', 'View Message', trash

    # Stats
    create_builtin_partial!('stats/chart')
    stats_section = find_or_create_section('Stats', '/stats')
    p.find_or_create! 'stats/index', 'Stats', stats_section

    # Applications
    create_builtin_partial!('applications/form')
    apps = find_or_create_section('Applications', '/applications')
    p.find_or_create! 'applications/edit', 'Edit Application', apps
    p.find_or_create! 'applications/show', 'Application', apps
    p.find_or_create! 'applications/index', 'List Applications', apps

    if provider.settings.multiple_applications.allowed?
      p.find_or_create! 'applications/new', 'New Application', apps
    end

    if provider.multiservice?
      p.find_or_create! 'applications/choose_service', 'Choose Service', apps
    end

    # Application Alerts
    alerts = find_or_create_section('Application Alerts', '/application/alerts')
    p.find_or_create! 'applications/alerts/index', 'List Alerts', alerts

    # Invoices
    invoices_section = find_or_create_section('Invoices', '/invoices')
    p.find_or_create! 'invoices/index', 'Invoices list', invoices_section
    p.find_or_create! 'invoices/show', 'Invoice details', invoices_section

    # Account Plans
    account_plans_section = find_or_create_section('Account Plans', '/account_plans')
    p.find_or_create! 'account_plans/index', 'Change Plan', account_plans_section

    # Account Plan Changes Wizard
    if provider.provider_can_use?(:plan_changes_wizard)
      account_plan_changes_section = find_or_create_section('Plan Changes Wizard', '/plan_changes_wizard')
      p.find_or_create! 'accounts/plan_changes/index', 'Plan Changes Wizard', account_plan_changes_section
    end

    # Account
    account_section = find_or_create_section('Account', '/account')
    p.find_or_create! 'account/show', 'Account Overview', account_section
    p.find_or_create! 'account/edit', 'Edit Account Details', account_section

    # Users
    users_section = find_or_create_section('Users', '/users')
    p.find_or_create! 'accounts/users/index', 'Users', users_section
    p.find_or_create! 'accounts/users/edit', 'User Edit', users_section

    # Personal Details
    users_section = find_or_create_section('User', '/user')
    p.find_or_create! 'user/show', 'Personal Details', users_section

    # Search
    search_section = find_or_create_section('Search', '/search')
    p.find_or_create! 'search/index', 'Search', search_section

    # Services
    if provider.settings.service_plans.allowed?
      create_service_plans_builtin_pages!
    end

    # Invitations
    invitations_section = find_or_create_section('Invitations', '/invitations')
    p.find_or_create! 'invitations/index', 'Sent invitations', invitations_section
    p.find_or_create! 'invitations/new', 'Create new invitations', invitations_section

    # Payment Gateway
    pg_section = find_or_create_section('Payment Gateway', '/payment_gateway')
    p.find_or_create! 'accounts/payment_gateways/edit', 'Edit Billing Address Form', pg_section
    p.find_or_create! 'accounts/payment_gateways/show', "Show User's Payment Details", pg_section

    # Errors
    errors = find_or_create_section('Errors', '/errors')
    p.find_or_create! 'errors/not_found', 'Not Found', errors, 'error'
    p.find_or_create! 'errors/internal_server_error', 'Internal Server Error', errors, 'error'
    p.find_or_create! 'errors/forbidden', 'Forbidden', errors, 'error'

    # Invitee signups
    invitee_signups_section = find_or_create_section('Invitee signups', '/invitee_signups')
    p.find_or_create! 'accounts/invitee_signups/show', 'Invitation signup form', invitee_signups_section
  end

  def create_multiapp_builtin_pages!
    section = @provider.builtin_sections.find_or_create!('Applications', '/applications')
    @provider.builtin_pages.find_or_create! 'applications/new', 'New Application', section
  end

  def create_multiservice_builtin_pages!
    section = @provider.builtin_sections.find_or_create!('Applications', '/applications')
    @provider.builtin_pages.find_or_create! 'applications/choose_service', 'Choose Service', section
  end

  def create_service_plans_builtin_pages!
    section = find_or_create_section('Services', '/services')
    @provider.builtin_pages.find_or_create! 'services/new', 'Subscribe to a service', section
    @provider.builtin_pages.find_or_create! 'services/index', 'List services', section
  end

  def create_builtin_partial!(system_name)
    unless provider.builtin_partials.find_by_system_name(system_name)
      provider.builtin_partials.create! do |p|
        p.system_name = system_name
        p.draft = CMS::Builtin::Partial.filesystem_templates.fetch(system_name).read
        p.liquid_enabled = true
      end.publish!
    end
  end

  def update_error_layout!(error_layout)
    # some providers have this
    if error_layout.published == "error"
      content = DeveloperPortal::VIEW_PATH.join('layouts/error.html.liquid').read
      error_layout.update_attributes(draft: content,
                                     title: 'Error layout', liquid_enabled: true)
      error_layout.publish!
    else
      Rails.logger.info "--> Error layout was changed."
    end
  end

  def create_error_layout!
    content = DeveloperPortal::VIEW_PATH.join('layouts/error.html.liquid').read
    provider.layouts.create!(system_name: 'error',
                            draft: content,
                            title: 'Error layout',
                            liquid_enabled: true).publish!
  end

  def builtin_static_pages
    forum_builtin_static_pages
  end

  def find_or_create_section(name, path, options = {})
    provider.builtin_sections.find_or_create!(name, path, options)
  end

  def setup_main_layout!
    provider.layouts.find_by_system_name("main_layout") || begin
      content = DeveloperPortal::VIEW_PATH.join('layouts/main_layout.html.liquid').read
      provider.layouts.create!(system_name: 'main_layout',
                               draft: content,
                               title: 'Main layout',
                               liquid_enabled: true).tap { |p| p.publish! }
    end
  end

  private

  def forum_builtin_static_pages
    return [] unless provider.provider_can_use?(:forum)

    forum             = find_or_create_section('Forum', '/forum')
    forum_categories  = find_or_create_section('Categories', '/forum/categories', parent: forum)
    forum_posts       = find_or_create_section('Posts', '/forum/posts', parent: forum)
    forum_topics      = find_or_create_section('Topics', '/forum/topics', parent: forum)
    forum_user_topics = find_or_create_section('User Topics', '/forum/user_topics', parent: forum)

    [
      { section: forum, system_name: 'forum/forums/show' },
      { section: forum_posts, system_name: 'forum/posts/index' },
      { section: forum_posts, system_name: 'forum/posts/new' },
      { section: forum_posts, system_name: 'forum/posts/show' },
      { section: forum_posts, system_name: 'forum/posts/edit' },
      { section: forum_topics, system_name: 'forum/topics/my' },
      { section: forum_topics, system_name: 'forum/topics/show' },
      { section: forum_topics, system_name: 'forum/topics/new' },
      { section: forum_topics, system_name: 'forum/topics/edit' },
      { section: forum_user_topics, system_name: 'forum/user_topics/index' },
      { section: forum_categories, system_name: 'forum/categories/index' },
      { section: forum_categories, system_name: 'forum/categories/show' },
      { section: forum_categories, system_name: 'forum/categories/new' },
      { section: forum_categories, system_name: 'forum/categories/edit' }
    ]
  end

  def root
    provider.builtin_sections.root || find_or_create_section('Root', '/', root: true, parent: nil)
  end

  def build_builtin_static_page(attributes)
    provider.builtin_static_pages.build do |l|
      l.system_name = attributes[:system_name]
      l.section = attributes[:section]
    end
  end

end
