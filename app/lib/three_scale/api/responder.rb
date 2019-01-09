class ThreeScale::Api::Responder < ActionController::Responder

  private

  def api_behavior
    resource = serializable
    resource = representer.prepare(resource) unless resource.frozen?

    case
    when get?
      display(resource, status: :ok) if controller.stale?(resource)
    when post? # create
      display resource, status: :created, location: api_location
    when put? || patch? # update
      display resource, status: :ok
    when delete?
      head :ok
    else
      head :no_content
    end
  end

  def api_location
    options.fetch(:location) { controller.request.query_parameters.merge(id: resource.id) }
  end

  def navigation_location
    options.fetch(:location) do
      params = controller.params.slice(:controller)
      params.merge!(controller.request.query_parameters)
      params[:id] = resource.id
      params[:action] = :show
      controller.url_for(params)
    end
  end


  def representer
    representer = options[:representer] || controller.representer_for(format, serializable, @options)
    representer.tap do |representer|
      # FIXME: this is really nasty way
      options = (Rails.application.config.representer.default_url_options ||= {})
      options[:host] = controller.request.host
    end
    representer
  end

  def display_errors
    controller.render format => resource_errors, :status => error_status
  end

  def resource_errors
    case represent_on_error
    when :resource
      representer.prepare(resource)
    else
      super
    end
  end

  def represent_on_error
    options[:represent_on_error] || :resource_errors
  end

  def error_status
    case
    when delete?
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
      :forbidden # should be more like :conflict (409)
    else
      :unprocessable_entity
    end
  end

  def serializable
    @serializable ||= begin
      resource = options.fetch(:serialize){ self.resource }
      resource = resource.is_a?(ActiveRecord::Relation) ? ordered_relation(resource).to_a : resource

      resource
    end
  end

  def ordered_relation(relation)
    if System::Database.postgres? && relation.order_values.empty?
      relation.order(:id)
    else
      relation
    end
  end
end
