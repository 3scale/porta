# frozen_string_literal: true

# This module encapsulates behaviour needed for Buyer, to change its
# Plan with respect to the permissions set on the judging object
# (Service for ApplicationPlans, Provider for AccountPlan and
# ServicePlan)
#
# Both Provider and Service should quack like an 'Issuer', that is
# respond to:
#
#  +plan_change_permission(plan_type, :new_contract => true/false)+ - returns one of Logic::PlanChanges::PERMISSIONS
#
# On Contract, the important methods are:
#
# +can_change_plan?+ - returns true if any form of change is possible
# +buyer_changes_plan+ - triggers the change (or request to change) of a plan
# +plan_change_permission_name+ - returns name of the allowed action
# +plan_change_permission_warning+ - returns warning message of the allowed action
#
module Logic
  module PlanChanges

    PERMISSIONS = [[ "Request a plan change", :request ],
                   [ "Change the plan directly", :direct ],
                   [ "Only request a plan change", :credit_card],
                   [ "Request Credit Card entry for paid plans", :request_credit_card],
                   [ "Don't allow plan changes", :none ]]


    module Contract
      # Returns true, if +Buyer+ is able to ask for some kind of
      # plan change on this contract (so both :request and :direct
      # permission trigger true).
      #
      # Generally speaking, the plan of an EXISTING contract can be changed if
      #
      # - the issuer permits to do so
      # - the issuer has published plans that can be selected
      # - the contract is 'live' (in case it suports lifecycle)
      #
      # New contract can change plan if and only if the issuer allows to
      # do so, no other condition is required.
      #
      def can_change_plan?(issuer = self.plan.issuer)
        return false unless issuer
        # get type from passed plan or from reflection if plan is not available
        type = plan ? plan.class : self.class.reflect_on_association(:plan).class_name

        if self.new_record?
          issuer.plan_change_permission(type, :new_contract => true) != :none
        else
          permission = issuer.plan_change_permission(type, :new_contract => false)
          allowed = permission && permission != :none
          plans_present = issuer.issued_plans.by_type(type).published.size > 0

          live = if self.has_lifecycle?
                   self.state.present? && self.live?
                 else
                   true
                 end

          allowed && plans_present && live
        end
      end

      def provider_changes_plan!(new_plan)
        issuer = self.plan.issuer
        permission = issuer.plan_change_permission(self.plan.class)

        self.change_plan!(new_plan)
      end

      # Depending on the permissions of the plan issuer, this method
      # either changes the plan directly, requests its change or raises
      # and exception if it is not allowed.
      #
      def buyer_changes_plan!(plan)
        issuer = self.plan.issuer
        permission = issuer.plan_change_permission(self.plan.class)

        case permission
        when :direct
          direct_plan_change_actions(plan)
        when :request
          request_plan_change_actions(plan)
        when :credit_card
          if self.user_account.credit_card_stored?
            direct_plan_change_actions(plan)
          else
            request_plan_change_actions(plan)
          end
        when :request_credit_card
          if plan.free? || self.user_account.credit_card_stored?
            direct_plan_change_actions(plan)
          else
            "Please enter your credit card before changing the plan."
          end
        else
          raise "Invalid plan change settings for #{plan.class}(#{plan.id})"
        end
      end

      # TODO: DRY with +plan_change_permission_name+
      #
      def plan_change_permission_warning
        permission = self.plan.issuer.plan_change_permission(self.plan.class)
        direct = 'Are you sure you want to change your plan?'
        request = 'Are you sure you want to request a plan change?'

        case permission.to_sym
        when :direct then direct
        when :request then request
        when :credit_card then self.user_account.credit_card_stored? ? direct : request
        when :request_credit_card then self.user_account.credit_card_stored? ? direct : request
        end
      end

      # Returns one of: 'Change Plan' / 'Request Change Plan' / nil (nothing allowed)
      #
      def plan_change_permission_name
        permission = self.plan.issuer.plan_change_permission(self.plan.class)

        case permission.to_sym
        when :direct, :request_credit_card then 'Change Plan'
        when :request then 'Request Plan Change'
        when :credit_card
          self.user_account.credit_card_stored? ? 'Change Plan' : 'Request Plan Change'
        end
      end

      private

      def request_plan_change_actions(plan)
        # TODO: unify the emails and remove 'case'
        case plan
        when AccountPlan
          account_plan_change_action(plan)
          'The plan change has been requested.'
        when ApplicationPlan
          application_plan_change_action(plan)
          'A request to change your application plan has been sent.'
        when ServicePlan
          service_plan_change_action(plan)
          'A request to change your service plan has been sent.'
        else
          raise "Cannot request change of plan #{plan.class}"
        end
      end

      def service_plan_change_action(plan)
        event = Services::ServicePlanChangeRequestedEvent.create(self, User.current, plan)
        Rails.application.config.event_store.publish_event(event)
      end

      def application_plan_change_action(plan)
        event = Applications::ApplicationPlanChangeRequestedEvent.create(self, User.current, plan)
        Rails.application.config.event_store.publish_event(event)
        PlansMessenger.plan_change_request(self, plan).deliver
        PlansMessenger.plan_change_request_made(self, plan).deliver
      end

      def account_plan_change_action(plan)
        AccountMessenger.plan_change_request(self.user_account, plan).deliver
        event = Accounts::AccountPlanChangeRequestedEvent.create(self.user_account, User.current, plan)
        Rails.application.config.event_store.publish_event(event)
      end

      def direct_plan_change_actions(plan)
        self.change_plan!(plan)
        plan.is_a?(ApplicationPlan) ? 'Plan change was successful.' : "Plan was successfully changed to #{plan.name}."
      end
    end

    module Provider
      # Plan 'Issuer' interface.
      #
      def plan_change_permission(type, opts = { :new_contract => false })
        raise "Provider is not issuer of #{type}s" unless type == AccountPlan

        if opts[:new_contract]
          :direct
        else
          settings.change_account_plan_permission.to_sym
        end
      end

      def set_change_account_plan_permission!(mode)
        raise 'This is provider only method!' unless self.provider?
        self.settings.change_account_plan_permission = mode
        self.settings.save!
      end

      def set_change_service_plan_permission!(mode)
        raise 'This is provider only method!' unless self.provider?
        self.settings.change_service_plan_permission = mode
        self.settings.save!
      end
    end

    module Service
      # Plan 'Issuer' interface.
      #
      def plan_change_permission(type, opts = { :new_contract => false })
        if opts[:new_contract]
          if type == ApplicationPlan && !self.buyer_can_select_plan?
            :none
          else
            :direct
          end
        else
          if type == ApplicationPlan
            self.buyer_plan_change_permission.to_sym
          elsif type == ServicePlan
            # TODO: make its own attribute for that
            self.account.settings.change_service_plan_permission.to_sym
          else
            raise "Service is not issuer of #{type}s"
          end
        end
      end

      def set_change_application_plan_permission!(mode)
        self.buyer_plan_change_permission = mode
        self.save!
      end

      def set_change_plan_on_app_creation_permitted!(yes_or_no)
        self.buyer_can_select_plan = yes_or_no
        self.save!
      end
    end
  end
end
