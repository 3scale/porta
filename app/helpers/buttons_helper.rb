# frozen_string_literal: true

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

  # Mini form with single <button> element, ready for fancy styling.
  #
  # == Options
  #
  # +method+:: HTTP method
  # +remote+:: if true, the request will be sent asynchronously (AJAXy)
  # +class+:: css class applied to the button element
  # +confirm+:: shows a confirmation dialog
  def fancy_button_to(label, url, options = {})
    form_attributes = {:method => (method = options.delete(:method) || :post),
                       :class  => 'button-to'}
    form_attributes[:style] = 'display:none' if options.delete(:visible) == false
    form_attributes['data-remote'] = true if options.delete(:remote)
    form_attributes['data-confirm'] = options.delete(:confirm)

    button_class = options.delete(:class)
    button_class ||= 'delete' if method == :delete
    button_class = join_dom_classes('action', button_class)

    button_attributes = { type: 'submit', class: button_class.strip }.merge(options)

    capture do
      form_tag url, form_attributes do
        tag.button(label, **button_attributes)
      end
    end
  end

  def pf_fancy_button_to(label, url, options = {})
    form_attributes = { method: options.delete(:method) || :post }
    form_attributes['data-remote'] = true if options.delete(:remote)
    form_attributes['data-confirm'] = options.delete(:confirm)

    button_class = options.delete(:class)

    button_attributes = { type: 'submit', class: button_class.strip }.merge(options)

    capture do
      form_tag url, form_attributes do
        tag.button(label, **button_attributes)
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

  def pf_link_to(label, url, options = {})
    variant = options.delete(:variant) || :link
    options[:class] = join_dom_classes("pf-c-button pf-m-#{variant}", options[:class])
    link_to label, url, options
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
