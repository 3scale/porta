module PlansHelper

  def can_create_plan?(plan)
    case plan.new
    when AccountPlan
      can?(:create, :account_plans) || can?(:create, plan)
    else
      can?(:create, :plans)
    end
  end

  def plan_free_or_paid plan
    plan.free? ? 'free' : 'paid'
  end

  def plan_header(plan)
    type = plan.class.name.titleize

    if plan.customized?
      header = "Custom #{type}"
    else
      header = "#{type}"
      header += ": #{plan.name}" if plan.name
    end

    url = if plan.is_a?(ApplicationPlan)
            edit_admin_application_plan_path(plan)
          elsif plan.is_a?(AccountPlan)
            edit_admin_account_plan_path(plan.id)
          else
            # TODO: ServicePlan (also - unify routes, haha)
            ''
          end

    link_to_unless_current header, url
  end

  def users_usage_message(buyers, plan_type)
    msg = plan_type == 'service_plan' ? pluralize(buyers, "service contract") + " set up" : pluralize(buyers, plan_type.split('_').first) + " created"
  end

  # Provider side!
  def plan_confirm_message(plan)
    if plan.customized?
      'This will delete all customizations. Are you sure?'
    else
      'Are you sure?'
    end
  end

  # Buyer side - let's not mix those!
  def review_change_plan_link(contract, text = 'Review/Change', id = "choose-plan-#{contract.id}")
    link_to text, url_for(:anchor => id), :id => id
  end

end
