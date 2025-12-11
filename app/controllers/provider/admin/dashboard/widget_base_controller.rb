# frozen_string_literal: true

class Provider::Admin::Dashboard::WidgetBaseController < Provider::Admin::BaseController
  include DashboardTimeRange

  helper_method :current_range, :previous_range, :widget

  respond_to :js

  def show
    render 'provider/admin/dashboard/widget/show'
  end

  def widget
    @widget ||= presenter.new(widget_data)
  end
end
