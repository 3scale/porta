# This makes CanCan work with Inherited resources.
#
# Inspiration comes from hexors's comment over here:
# http://github.com/ryanb/cancan/issues#issue/23
#
# TODO: Maybe this is no longer needed, as there is a new version of canca. Check it.
module CanCanHacks
  def self.included(base)
    class << base
      prepend(Module.new do
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
      end)
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
