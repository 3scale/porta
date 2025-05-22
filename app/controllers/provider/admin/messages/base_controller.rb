# frozen_string_literal: true

class Provider::Admin::Messages::BaseController < FrontendController
  helper_method :toolbar_props

  def pagination_params
    { page: params.permit(:page)[:page] || 1, per_page: params.permit(:per_page)[:per_page] || 20 }
  end

  def toolbar_props # rubocop:disable Metrics/MethodLength
    props = {
      totalEntries: @messages.total_entries,
      pageEntries: @messages.length,
      actions: [{
        label: 'Compose Message',
        href: new_provider_admin_messages_outbox_path,
        variant: :primary
      }],
      bulkActions: [{
        name: 'Delete',
        url: new_provider_admin_messages_bulk_trash_path(scope: scope),
        title: 'Delete selected messages',
        variant: 'danger'
      }],
      overflow: []
    }

    if can?(:export, :data)
      props[:overflow].append({ href: new_provider_admin_account_data_exports_path,
                                label: 'Export to CSV',
                                isShared: false,
                                variant: :secondary })
    end

    props
  end
end
