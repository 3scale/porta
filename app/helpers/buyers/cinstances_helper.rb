module Buyers::CinstancesHelper
  def link_to_cinstance_or_deleted(cinstance)
    if cinstance
      link_to(cinstance.name, admin_buyers_application_path(cinstance))
    else
      content_tag(:span, '(deleted app)', :class => 'deleted')
    end
  end

  def link_to_plan_edit(plan)
    if can?(:manage, :plans)
      link_to(plan.name, edit_polymorphic_path([:admin, plan]))
    else
      plan.name
    end
  end

  def link_to_service_edit(service)
    if can? :manage, :plans
      link_to(service.name, edit_admin_service_path(service))
    else
      service.name
    end

  end
end
