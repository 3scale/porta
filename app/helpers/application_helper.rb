if RUBY_VERSION < '1.9'
  require 'md5'
else
  require 'digest/md5'
end

# TODO: Let's try to find new homes for these guys. It's getting crowded here...


# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  # this is used just to not load font awesome in tests
  def capybara_webkit?
    Rails.env.test? && defined?(Capybara.current_driver) && Capybara.current_driver == :webkit
  end

  include ColumnSortingHelper

  def base_url
    options = {
        host: request.headers['X-Forwarded-For-Domain']
    }.delete_if{|_, value| !value }

    root_url(options)
  end

  def title(page_title)
    content_for(:title) { h(page_title.to_s) }
  end

  def default_title
    name = controller.class.name.underscore.tr('/', '.').sub(/_controller$/, '')
    controller_name = t(name,
                        scope: [:controller, :title],
                        default: controller.controller_name.humanize)

    action_name = t(action = controller.action_name,
                    scope: [:controller, :action, name],
                    default: action.humanize)

    "#{controller_name} - #{action_name}"
  end

  def link_to_unless_current_styled(text, url, options = {})
    link_to_unless_current text, url, options do |active_text|
      content_tag 'span', active_text, :class => 'active is-active'
    end
  end

  # Ensure that url starts with protocol (http or https)
  #
  # == Examples:
  #
  #   absolutize_url("http://example.com") # returns http://example.com
  #   absolutize_url("example.com")        # returns http://example.com
  #
  def absolutize_url(url)
    url =~ /\Ahttps?/ ? url : "http://#{url}"
  end


  def active?(current, stage)
    "class=\"active\"" if current == stage
  end

  # Used with URLs which were entered by users
  def render_url(url)
    url.blank? ? 'link not available' : absolutize_url(url)
  end

  # Render tab. This automaticaly handles ajax as well as non-ajax calls.
  #
  # == Arguments
  #
  # * +id+: id of current tab
  #
  # == Options
  #
  # * +of+: name of resource under which this tab belongs. (:service, :plan,
  #   ...)
  def tab(id, options = {}, &block)
    if request.xhr?
      yield
    else
      @tab = id
      layout = options[:of] ? "#{options[:of].to_s.pluralize}/" : ''
      layout << 'tabs'

      render :layout => layout, &block
    end
  end

  ##
  # Forum imported helpers

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('forum/feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
  end

  def pagination(collection)
    if collection.total_entries > 1
      "<p class='pages'>" + 'Pages'[:pages_title] + ": <strong>" +
      will_paginate(collection, :inner_window => 10, :next_label => "next"[], :prev_label => "previous"[]) +
      "</strong></p>"
    end
  end

  def next_page(collection)
    unless collection.current_page == collection.total_entries || collection.total_entries == 0
      "<p style='float:right;'>" + link_to("Next page"[], { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end

  def search_posts_title
    returning(params[:q].blank? ? 'Recent Posts'[] : "Searching for"[] + " '#{h params[:q]}'") do |title|
      title << " "+'by {user}'[:by_user,h(@user.display_name)] if @user
      title << " "+'in {forum}'[:in_forum,h(@forum.name)] if @forum
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /\A\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" +
      link_to(h($2.strip), forum_topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), forum_topic_path(@forum, topic), options)
    end
  end

  def avatar_for(user, size=62)
    email_hash = Digest::MD5.hexdigest(user.try!(:email) || "")

    image_tag "https://secure.gravatar.com/avatar.php?gravatar_id=#{email_hash}&rating=PG&size=#{size}", :size => "#{size}x#{size}", :class => 'photo'
  end

  def search_path(atom = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    prefix =
      if @topic
        options.update :topic_id => @topic, :forum_id => @forum
        :forum_topic
      elsif @forum
        options.update :forum_id => @forum
        :forum
      elsif @user
        options.update :user_id => @user
        :user
      else
        :search
      end
    atom ? send("formatted_#{prefix}_posts_path", options.update(:format => :atom)) : send("#{prefix}_posts_path", options)
  end

  # Join CSS classes to single space-separated string, ready for inserting into a "class"
  # attribute of a html element.
  #
  # Handles well empty or nil class names (does not include them).
  #
  # == Examples
  #
  # join_dom_classes('foo')             # "foo"
  # join_dom_classes('foo', 'bar')      # "foo bar"
  # join_dom_classes('foo', '')         # "foo"
  # join_dom_classes('foo', false)      # "foo"
  # join_dom_classes('foo', nil)        # "foo"
  # join_dom_classes('', nil, '  ')     # nil
  def join_dom_classes(*names)
    names.reject(&:blank?).join(' ')
  end

  # Join CSS classes to single string. Can accept Array or Hash like Slim template.
  #
  # :reek:NestedIterators {enabled: false}
  def css_class(*args)
    args.map do |arg|
      case arg
      when Array then arg.select(&:present?)
      when Hash then arg.select { |_,value| value.present? }.keys
      else arg
      end
    end.join(' ')
  end

  def boolean_status_img(enabled, opts = {})
    if enabled
      '<i class="included fa fa-check-circle-o" title="Enabled"></i>'.html_safe
    else
      '<i class="excluded fa fa-times-circle-o" title="Disabled"></i>'.html_safe
    end
  end

  # Returns sentence about used timezone with linking to its change.
  #
  def timezone_information(timezone = current_account.timezone)
    name = ActiveSupport::TimeZone.new(timezone).to_s
    name_or_link = if can?(:update, current_account) && current_account.provider?
                     link_to(name, edit_provider_admin_account_path)
                   else
                     name
                   end
    "Using time zone ".html_safe + name_or_link
  end

  def help_url
    "http://www.3scale.net/support/product-configuration/"
  end

  def favicon_for account
    return if account.nil?
    return if account.settings.favicon.blank?
    ThreeScale::Warnings.deprecated_method!(:favicon_for)

    types = {'ico' => 'x-icon', 'png' => 'png',  'gif' => 'gif'}
    type = account.settings.favicon.split('.').last
    type = types[type] or return
    "<link rel=\"icon\" href=\"#{account.settings.favicon}\" type=\"image/#{type}\" />".html_safe
  end

  def error_messages_for(*params)
    ignore_me = ['Account is invalid', 'Bought cinstances is invalid']
    options = params.extract_options!.symbolize_keys

    objects = if object = options.delete(:object)
      [object].flatten
              else
      params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
              end

    count  = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:object_name] ||= params.first

      I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
        header_message = if options.include?(:header_message)
          options[:header_message]
                         else
          object_name = options[:object_name].to_s.tr('_', ' ')
          object_name = I18n.t(object_name, :default => object_name, :scope => [:activerecord, :models], :count => 1)
          locale.t :header, :count => count, :model => object_name
        end
        message = options.include?(:message) ? options[:message] : locale.t(:body)
        error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) unless ignore_me.include?(msg) } }.join

        contents = ''
        contents << content_tag(options[:header_tag] || :h2, header_message.html_safe) unless header_message.blank?
        contents << content_tag(:p, message.html_safe) unless message.blank?
        contents << content_tag(:ul, error_messages.html_safe)
        content_tag(:div, contents.html_safe, html)
      end
    else
      ''
    end
  end

  def format_text(text)
    RedCloth.new(text).to_html
  end

  def chop(name, l = 15)
    name.length > l ? name[0...l]+'...' : name
  end

  def partner_accounts_plural_text_or_link
    text = h(pluralize(current_account.buyer_accounts.count, "account"))
    if can? :manage, :partners
      link_to text, admin_buyers_accounts_path
    else
      text
    end
  end

  def link_or_text_to_settings_or_site
    # complicated ain't it? welcome to the realm of reusing everything
    if can? :manage, :settings
      link_to "Settings", admin_site_settings_path
    else
      "Settings"
    end
  end

  def account_plan_link_or_text
    text = 'Account plan'
    if can? :manage, :plans
      link_to text, admin_buyers_account_plans_path(current_account)
    else
      text
    end
  end


  def account_plans_count_link_or_text
    text = current_account.account_plans.stock.size
    if can? :manage, :plans
      link_to text, admin_buyers_account_plans_path
    else
      text
    end
  end

  def partner_accounts_count_link_or_text
    text = current_account.buyers.size
    if can? :manage, :partners
      link_to text, admin_buyers_accounts_path
    else
      text
    end
  end

  def can_be_destroyed?(object)
    !object.respond_to?(:can_be_destroyed?) ||
      ( object.respond_to?(:can_be_destroyed?) && object.can_be_destroyed? )
  end

  def link_to_export_widget_for(collection)
    return unless can?(:export, :data)
    link_to(new_provider_admin_account_data_exports_path, id: 'export-to-csv', class: 'ExportLink', title: 'Export to CSV') do
      content_tag(:i, '', class: 'fa fa-file-excel-o') + ' Export all ' + collection.capitalize
    end
  end

  def impersonating?
    current_user.impersonation_admin? && !current_account.master?
  end

  def saas?
    ThreeScale.tenant_mode.multitenant?
  end

  def major_and_minor_version_path
    full_version = System::Deploy.info.release || '2.0.0'
    simple_version = /^(?:(\d+)\.)?(?:(\d+))/.match(full_version)
    if saas?
      "red_hat_3scale/#{simple_version[1]}-saas"
    else
      "red_hat_3scale_api_management/#{simple_version[1]}.#{simple_version[2]}"
    end
  end

  def docs_base_url
    I18n.t('docs.base_url', major_and_minor_version_path: major_and_minor_version_path)
  end

  def call_to_action?
    return false unless ThreeScale.config.redhat_customer_portal.enabled
    return false unless current_user.admin?

    # This also prevents a bug in the fields definition feature to throw an unexpected exception when Account.master.field_value is invoked
    return false if current_account.master?

    unlinked_paid_account?
  end

  def unlinked_paid_account?
    !current_account.field_value('red_hat_account_verified_by').presence && current_account.paid?
  end
end
