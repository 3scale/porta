module ErrorHandling
  extend ActiveSupport::Concern

  included do
    include Handlers
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from WillPaginate::InvalidPage, with: :handle_not_found
    before_bugsnag_notify :add_user_info_to_bugsnag
    # rescue_from StandardError, :with => :handle_server_error
  end

  module Handlers
    protected

    def handle_server_error(exception)
      System::ErrorReporting.report_error(exception)
      handle_error(exception, :internal_server_error)
    end

    def handle_not_found(exception)
      handle_error(exception, :not_found)
    end

    def handle_access_denied(exception)
      handle_error(exception, :forbidden)
    end

    def handle_error(exception, status)
      logger.error "Handling Exception: #{exception} with status #{status}"
      logger.debug exception.backtrace.join("\n") if exception.try!(:backtrace)

      @_exception_handled = exception

      # our tests are sending this format without appropriate accepts header
      # request.format = :html if request.format.url_encoded_form

      # this is prepared for handling errors in js/json/xml
      title = status.to_s.humanize

      respond_to do | format |
        format.html do
          if Account.is_admin_domain?(request.host) || site_account.master?
            handle_provider_side(status, exception, title)
          else
            handle_buyer_side(status)
          end
        end

        format.json { render json: {status: title}, status: status }

        format.xml  { render nothing: true, status: status }

        format.any  { render plain: title, status: status }
      end
    end

    def add_user_info_to_bugsnag(notification)
      # Set the user that this bug affected
      # Email, name and id are searchable on bugsnag.com
      site_account = try(:site_account)
      current_user = User.current
      current_account = current_user.try(:account)

      notification.user = {
          provider: site_account.try(:org_name),
          provider_id: site_account.try(:id),
          email: current_user.try(:email),
          account_id: current_account.try(:id),
          id: current_user.try(:id)
      }

      # Add some app-specific data which will be displayed on a custom
      # "Provider" tab on each error page on bugsnag.com
      notification.add_tab(:provider, {
          name: site_account.try(:org_name),
          admin_domain: site_account.try(:self_domain),
          domain: site_account.try(:domain)
      })
    end

    def notify_newrelic(exception)
      return unless defined?(NewRelic)

      NewRelic::Agent.notice_error(exception)
    end

    def handle_provider_side(status, exception, title)
      render layout: "error",
             template: "errors/provider/#{status}",
             status: status,
             locals: { exception: exception, title: title,
                            site_account: defined?(site_account) ? site_account : Account.master }
    end

    def handle_buyer_side(status)
      add_liquid_view_paths

      page_name = "errors/#{status}"

      if (error_page = site_account.builtin_pages.find_by_system_name(page_name))
        assign_drops page: Liquid::Drops::Page.new(error_page)
        layout = error_page.layout.try!(:system_name)
      end

      render page_name, layout: layout || 'error'.freeze, status: status, handlers: [:liquid]
    end
  end
end
