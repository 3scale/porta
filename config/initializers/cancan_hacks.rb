# frozen_string_literal: true

# This makes CanCan work with Inherited resources.
#
# Inspiration comes from hexors's comment over here:
# http://github.com/ryanb/cancan/issues#issue/23
#
# TODO: Maybe this is no longer needed, as there is a new version of canca. Check it.
module CanCanHacks
  class InheritedResource < CanCan::ControllerResource
    def load_resource_instance
      if parent?
        @controller.send :association_chain
        @controller.instance_variable_get("@#{instance_name}")
      elsif new_actions.include? @params[:action].to_sym
        resource = @controller.send :build_resource
        assign_attributes(resource)
      else
        @controller.send :resource
      end
    end

    def resource_base
      @controller.send :end_of_association_chain
    end
  end

  class CustomControllerResource < CanCan::ControllerResource
    def authorization_action
      action = @params[:action].to_sym

      if @controller.request.get? && !%i[index edit].include?(action)
        :show
      else
        super
      end
    end
  end

  module ControllerAdditions
    # [default] custom controller [GET] methods are being authorized separately
    # [custom] custom controller [GET] methods are being authorized as show method
    def cancan_resource_class
      if ancestors.map(&:to_s).include? 'InheritedResources::Actions'
        InheritedResource
      else
        CustomControllerResource
      end
    end

    def authorize_resource(options = {})
      if inherits_resources?
        before_action :authorize_inherited_resource
      else
        super(options)
      end
    end

    private

    def inherits_resources?
      included_modules.include?(InheritedResources::BaseHelpers)
    end
  end

  def self.included(base)
    class << base
      prepend ControllerAdditions
    end
  end

  private

  def authorize_inherited_resource
    authorize! params[:action].to_sym, resource_for_authorization
  end

  def resource_for_authorization
    case params[:action].to_sym
    when :index
      resource_class
    when :new, :create
      build_resource
    else
      resource || resource_class
    end
  end
end

ActionController::Base.send(:include, CanCanHacks)
