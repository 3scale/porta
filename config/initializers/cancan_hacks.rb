# frozen_string_literal: true

# CanCan customizations for custom GET actions
#
# This modifies CanCan's authorization behavior so that custom GET actions
# (those not in [:index, :new, :edit]) are authorized as :show actions
# instead of being authorized separately.
module CanCanHacks
  class CustomControllerResource < CanCan::ControllerResource
    def authorization_action
      action = @params[:action].to_sym

      if @controller.request.get? && !%i[index new edit].include?(action)
        :show
      else
        super
      end
    end
  end

  module ControllerAdditions
    # Custom controller GET methods are authorized as :show action
    def cancan_resource_class
      CustomControllerResource
    end
  end

  def self.included(base)
    class << base
      prepend ControllerAdditions
    end
  end
end

ActionController::Base.send(:include, CanCanHacks)
