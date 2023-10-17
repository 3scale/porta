# frozen_string_literal: true

class Provider::Admin::Messages::BaseController < FrontendController
  helper_method :toolbar_props

  def pagination_params
    { page: params.permit(:page)[:page] || 1, per_page: params.permit(:per_page)[:per_page] || 20 }
  end

  def toolbar_props
    {
      totalEntries: @messages.total_entries,
      pageEntries: @messages.length,
      newMessageHref: new_provider_admin_messages_outbox_path,
      bulkActions: [{
        name: 'Delete',
        url: new_provider_admin_messages_bulk_trash_path(scope: scope),
        title: 'Delete selected messages',
        variant: 'danger'
      }]
    }
  end
end
