# frozen_string_literal: true

module ApplicationHelper
  def base_url
    options = {
        host: request.headers['X-Forwarded-For-Domain']
    }.delete_if{|_, value| !value }

    root_url(options)
  end

  def page_title
    "#{content_for(:title) || default_page_title} | Red Hat 3scale API Management"
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
    names.compact_blank.join(' ')
  end

  def docs_base_url
    I18n.t('docs.base_url', docs_version: System::Deploy.info.docs_version)
  end

  def call_to_action?
    return false unless ThreeScale.config.redhat_customer_portal.enabled
    return false unless current_user.admin?

    # This also prevents a bug in the fields definition feature to throw an unexpected exception when Account.master.field_value is invoked
    return false if current_account.master?

    !current_account.field_value('red_hat_account_verified_by').presence && current_account.paid?
  end

  private

  def default_page_title
    name = controller.class.name.underscore.tr('/', '.').sub(/_controller$/, '')
    controller_name = t(name, scope: %i[controller title],
                              default: controller.controller_name.humanize)

    action = controller.action_name
    action_name = t(action, scope: [:controller, :action, name],
                            default: action.humanize)

    "#{controller_name} - #{action_name}"
  end
end
