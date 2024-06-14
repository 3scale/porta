# frozen_string_literal: true

class Provider::Admin::ApiDocsIndexPresenter
  include ::Draper::ViewHelpers
  include ApplicationHelper

  attr_reader :scope, :user, :pagination_params, :sorting_params, :service

  delegate :total_entries, to: :api_docs_services

  def initialize(scope:, user:, params:)
    @scope = scope
    @user = user

    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @sorting_params = "#{params[:sort].presence || 'created_at'} #{params[:direction].presence || 'asc'}"
    @service = scope if scope.is_a?(Service)
  end

  def any_api_docs?
    api_docs_services.any?
  end

  def api_docs_services
    @api_docs_services ||= scope.api_docs_services
                                .permitted_for(user)
                                .order(sorting_params)
                                .paginate(pagination_params)
                                .includes(:service)
  end

  def props # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    {
      activeDocs: api_docs_services.map do |api_doc| # rubocop:disable Metrics/BlockLength
        {
          id: api_doc.id,
          name: api_doc.name,
          href: h.preview_admin_api_docs_service_path(api_doc),
          actions: {
            toggle: {
              title: api_doc.published? ? 'Hide' : 'Publish',
              href: h.toggle_visible_admin_api_docs_service_path(api_doc)
            },
            edit: {
              title: 'Edit',
              href: h.edit_admin_api_docs_service_path(api_doc),
            },
            delete: {
              title: 'Delete',
              href: h.admin_api_docs_service_path(api_doc),
            }
          },
          systemName: api_doc.system_name,
          state: api_doc.published? ? 'visible' : 'hidden',
          service: api_doc.service&.name,
          swaggerVersion: api_doc.swagger_version,
          swaggerUpdate: if api_doc.needs_swagger_update?
                           {
                             title: I18n.t('admin.api_docs.base.index.update_link_text'),
                             href: I18n.t('admin.api_docs.base.index.update_link', docs_base_url: docs_base_url)
                           }
                         end
        }
      end,
      newActiveDocPath: new_api_docs_service_path,
      totalEntries: total_entries,
      isAudience: service.nil?
    }
  end

  def new_api_docs_service_path
    scope.is_a?(Service) ? h.new_admin_service_api_doc_path(scope) : h.new_admin_api_docs_service_path
  end
end
