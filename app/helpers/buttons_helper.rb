module ButtonsHelper

  DATA_ATTRIBUTES = [:confirm, :method, :remote, :'disable-with', :disabled]
  #TODO: refactoring: move buttons helpers to own helper

  def important_icon_link(title, icon_name, link, options = {:class => 'important-button'})
    link_to "#{icon(icon_name)} #{title}".html_safe, link, options
  end

  def action_link_to(action, url, options = {})
    label = options.delete(:label) || action.to_s.titleize
    options[:class] = join_dom_classes(options[:class], action.to_s.presence)

    fancy_link_to(label, url, options)
  end

  # Accessible link button ready for fancy styling
  #
  def fancy_link_to(label, url, options = {})
    options[:class] ||= 'delete' if options[:method].try!(:to_sym) == :delete
    options[:class] = join_dom_classes('button-to', 'action', options[:class].presence)

    data_attr_options!(options)

    switch_link label, url, options
  end

  # Mini form with signle <button> element, ready for fancy styling.
  #
  # == Options
  #
  # +method+:: HTTP method
  # +remote+:: if true, the request will be sent asynchronously (AJAXy)
  # +class+:: css class applied to the button element
  def fancy_button_to(label, url, options = {})
    form_attributes = {:method => (method = options.delete(:method) || :post),
                       :class  => join_dom_classes('button-to', options.delete(:remote) && 'remote')}
    form_attributes[:style] = 'display:none' if options.delete(:visible) == false

    button_class = options.delete(:class)
    button_class ||= 'delete' if method == :delete
    button_class = join_dom_classes('action', button_class)

    confirmation = if (confirm = options.delete(:confirm)).blank?
                     { }
                   else
                     { :onclick => "return confirm('#{confirm}');" }
                   end

    button_attributes = {:type => 'submit', :class => button_class.strip }.merge(confirmation).merge(options)

    capture do
      form_tag url, form_attributes do
        content_tag 'button', label, button_attributes
      end
    end
  end

  # Convenience method for buttons to some action. The action symbol will be used for button's
  # label and it's css class by default:
  #
  # == Example
  #
  #   # Button with label "Vaporize" and class "vaporize", doing a post to
  #   # vaporize_everything_path when pressed.
  #   action_button_to :vaporize, vaporize_everything_path
  #
  def action_button_to(action, url, options = {})
    label = options.delete(:label) || action.to_s.titleize
    options[:class] = join_dom_classes(options[:class], action.to_s)

    fancy_button_to(label, url, options)
  end

  # Button for deleting stuff.
  #
  # This is a shortcut for
  #
  #   fancy_button_to("Delete", url, :method => :delete, :class => 'delete')
  def delete_button_for(url, options = {})
    action_button_to(:delete, url, options.merge(:method => :delete))
  end

  def delete_link_for(url, options = {})
    action_link_to :delete, url, options.reverse_merge(:method => :delete)
  end

  def button_to_toggle_suspend_buyer_user(user)
    if user.active?
      fancy_button_to('Suspend', suspend_admin_buyers_account_user_path(user.account, user), class: 'action off')
    elsif user.suspended?
      fancy_button_to('Unsuspend', unsuspend_admin_buyers_account_user_path(user.account, user), class: 'action ok')
    end
  end

  def link_to_activate_buyer_user(user)
    action_link_to('activate', activate_admin_buyers_account_user_path(user.account, user), method: :post, class: 'action')
  end

  def button_activate_or_suspend(user)
    account = user.account
    if user.active?
      fancy_button_to('Suspend', suspend_admin_buyers_account_user_path(account, user), class: 'action off')
    elsif user.suspended?
      fancy_button_to('Unsuspend', unsuspend_admin_buyers_account_user_path(account, user), class: 'action ok')
    elsif user.pending? && can?(:activate, user)
      link_to_activate_buyer_user(user)
    end
  end

  def dropdown_button( title, url = nil, opts = {}, &block)
    css_class = opts.delete(:important) ? 'important-button' : 'less-important-button'

    main_item = if url.nil?
      title
                else
      link_to(title, url, opts.slice!(:id).merge(:class => css_class))
                end

    list = content_tag(:ul, capture(&block), :class => 'dropdown')

    caret = %{<a class="#{css_class} dropdown-toggle" href="#">
                 <i class="fa fa-caret-down"></i>
              </a>}.html_safe

    content_tag(:div, main_item + list + caret, opts.merge(:class => 'button-group'))
  end

  # Usage:
  #
  # dropdown_link 'Preview published', cms_published_url(@page), :target => "_blank", 'data-preview' => :published
  #
  #   or
  #
  # dropdown_link '<button type="submit" value="Publish"></button>'
  #
  def dropdown_link(*args)
    if args.size > 1
      content_tag :li, link_to(*args)
    else
      content_tag :li, args.first
    end
  end

  protected

  def javascript_alert_url(text)
    "javascript:alert('#{escape_javascript(text)}');javascript:void(0);"
  end

  def data_attr_options! options
    DATA_ATTRIBUTES.each do |key|
      options["data-#{key}".to_sym] = options.delete(key) if options[key]
    end
  end
end
