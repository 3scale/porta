# frozen_string_literal: true

# TODO: replace plans_helper.rb ?

World(PlanHelpers)

# module PlanHelpers

#   def create_plan(type, options)
#     options[:cost] ||= 0

#     plan = mock_plan(options.merge(type: "#{type}_plan"))

#     if (flags = options[:flags]) && flags.include?('default') || options[:name] == "Default"
#       make_plan_default(plan)
#     end
#     plan.publish! if flags.include?('published')

#     plan
#   end

#   def default_plan?(plan)
#     plans_method = "#{plan.class.to_s.underscore}s"
#     plan == plan.issuer.send(plans_method).default
#   end

#   def make_plan_default(plan)
#     plans_method = "#{plan.class.to_s.underscore}s"
#     plan.issuer.send(plans_method).default = plan
#     plan.issuer.save!
#   end

#   def sign_up(buyer, name)
#     plan = Plan.find_by!(name: name)
#     buyer.buy!(plan)
#   end

#   def change_plan_permission_to_sym(mode)
#     case mode
#     when /directly/ then :direct
#     when /only with credit card/ then :credit_card
#     when /by request/ then :request
#     when /credit card required/ then :request_credit_card
#     end
#   end

#   private

#   def mock_plan(options)
#     type = options[:type]
#     issuer = options[:issuer]
#     issuer = issuer.first_service! if issuer.is_a?(Account) && ['application plan', 'service plan'].include?(type)

#     plan_name = options[:name]
#     create_options = {
#       name: plan_name,
#       issuer: issuer,
#       cost_per_month: options[:cost]
#     }

#     create_options.merge(system_name: plan_name) if master_plan?(plan_name)

#     FactoryBot.create(type, create_options)
#   end

#   def master_plan?(name)
#     %w[base plus power1M power2M power3M power5M pro3M pro5M pro10M pro20M enterprise].include?(name)
#   end
# end
