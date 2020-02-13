# frozen_string_literal: true

module Logic
  module ProviderUpgrade
    ENTERPRISE_PLAN = 'enterprise'
    ENTERPRISE_PRODUCT = 'enterprise'

    module Provider
      # @return [Hash<Symbol,Array<Symbol>>]
      def available_plans
        available_plans? ? PlanRulesCollection.all_plan_rules_with_switches : {}
      end

      # @return [::Array<::Settings::Switch>]
      def available_switches
        settings.switches.values
      end

      def upgrade_to_provider_plan!(new_plan)
        # consider just returning instead as Someone can mangle the
        # input to trigger it
        raise 'Missing credit card!' unless credit_card_stored?
        raise "Cannot upgrade to plan #{new_plan.system_name}" unless can_upgrade_to?(new_plan)
        force_upgrade_to_provider_plan!(new_plan)
      end

      # intended to be called from console
      # only active and show switches
      def force_upgrade_to_provider_plan!(new_plan)
        change_plan!(new_plan)
        make_switches_on switches_for_plan(new_plan)
        limits = new_plan.limits.presence
        update_provider_constraints_to(limits, "Upgrading limits to match plan #{new_plan.system_name}") if limits
      end

      # intended to be called for partners stuff and console
      def force_to_change_plan!(new_plan)
        change_plan!(new_plan)
        switches_on = switches_for_plan(new_plan)
        make_switches_on(switches_on)
        make_switches_off(switches_on)
      end

      def hideable_switches
        # TODO: This is probably a broken feature and we have to address this issue.
        #
        # We used to have all switches hardcoded in this file, above. They used to be all as Strings, and this method was implemented 6 years ago
        # (see https://github.com/3scale/system/commit/d7a447c41854fcd69ddb91fb36cbb053a6fb23a3#diff-feacd82d9caaddafd3ed1da2edb64f26R66)
        # searching an String in an array of Strings.
        #
        # In another PR, 2 years ago, those switches hardcoded became Symbols
        # (see https://github.com/3scale/system/commit/53a1965159734a4eaf2cf732e6bf35894ab5b8ea)
        # but this method didn't change, and was doing `settings.switches.select { |name, switch| array_of_symbols.exclude?(name.to_s) && switch.hideable? }`,
        # (see https://github.com/3scale/system/blob/43d09fe07824fea37ef6dfb9ee3b1eeac0abb27a/app/lib/logic/provider_upgrade.rb#L131),
        # so the whole method was functioning like if the code was just `settings.switches.select { |_name, switch| switch.hideable? }`.
        # Probably this was not the intention.
        #
        # There used to be a test but it was stubbing this constant with a content of a String that is not what it actually contains
        # (see https://github.com/3scale/system/blob/43d09fe07824fea37ef6dfb9ee3b1eeac0abb27a/test/unit/logic/provider_upgrade_test.rb#L28)
        #
        # In https://github.com/3scale/system/pull/9326, this method changes to `settings.switches.select { |_name, switch| switch.hideable? }`,
        # intending to fix this problem in the next PR.
        #
        settings.switches.hideable
      end

      def has_best_plan?
        bought_cinstance.plan.best_plan?
      end

      def can_upgrade_by_email?(plan)
        plan.system_name.include?(ENTERPRISE_PLAN) &&
          bought_cinstance.plan.system_name.exclude?(ENTERPRISE_PLAN)
      end

      def can_upgrade_to?(plan)
        PlanRulesCollection.can_upgrade?(from: (bought_plan.original || bought_plan), to: plan)
      end

      def first_plan_with_switch(switch)
        PlanRulesCollection.lowest_ranked_plan_with_switch(switch) if available_plans?
      end

      def update_provider_constraints_to(limits, comment)
        new_limits = limits.merge(provider: self, audit_comment: comment)
        # assigning to the model, because #provider_constraints
        # would return different null object every time it is called
        # so if this method would be called twice,
        # it would try to create second constraints instead of updating the existing
        self.provider_constraints = constraints = provider_constraints
        constraints.update_attributes(new_limits)
      end

      private

      def switches_for_plan(plan)
        available_plans? ? plan.switches : []
      end

      def available_plans?
        partner.blank?
      end

      def change_plan!(new_plan)
        bought_cinstance.change_plan!(new_plan)
        enterprise_plan_product(new_plan)
      end

      def enterprise_plan_product(new_plan)
        return unless new_plan.system_name.include? ENTERPRISE_PLAN
        settings.update_attribute :product, ENTERPRISE_PRODUCT
      end

      def make_switches_on(switches_on)
        switches_on.reject(&method(:allowed_switch?)).each do |switch|
          settings.public_send("allow_#{switch}!")
          show_switch!(switch)
        end
      end

      def show_switch!(switch)
        return if switch == :require_cc_on_signup && provider_can_use?(switch)
        return unless Switches::THREESCALE_VISIBLE_SWITCHES.include?(switch)
        settings.public_method("show_#{switch}!").call
      end

      def allowed_switch?(switch)
        settings.public_send(switch).allowed?
      end

      def make_switches_off(switches_on)
        switches_off = Switches::SWITCHES - switches_on
        switches_off.each do |switch|
          next if settings.send(switch).denied?
          settings.send("hide_#{switch}!") if Switches::THREESCALE_VISIBLE_SWITCHES.include?(switch)
          settings.send("deny_#{switch}!")
        end
      end
    end
  end
end
