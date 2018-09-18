class Provider::Admin::Dashboard::Service::IntegrationErrorsController < Provider::Admin::Dashboard::Service::BaseController
  respond_to :json

  protected

  def widget_data
    { value: had_errors? }
  end

  def had_errors?
    errors = errors_service.list(service.id, page: 1, per_page: 1)

    if errors.presence && (last_error = errors.first)
      current_range.cover?(last_error.timestamp.to_date)
    end
  end

  def errors_service
    @errors_service ||= IntegrationErrorsService.new
  end
end
