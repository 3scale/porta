module Admin::PlansHelper

  # Generates 'publish' or 'hide' button markup for a plan.

  def publish_button_for(plan)
    text = plan.published? ? 'hide' : 'publish';
    path = plan.published? ? hide_admin_plan_path(plan) : publish_admin_plan_path(plan)
    fancy_button_to text, path, :method => :post, :class => text
  end

  def default_plan_checkbox_for(plan)
    if plan.published?
      state = plan.master? ? true : false
      check_box_tag :default, plan.id, state, {:class => 'master-select'}
    end
  end
end