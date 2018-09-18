module Buyer::ContractsHelper

  # TODO: - REFACTOR to render ALL and handle it differently in JS
  # see accounts/account_plans/index.html.erb
  #
  def render_plan_switcher( plans, selected)
    plans.map do |plan|
      opts = { :class => 'plan-preview', 'data-plan-id' => plan.id }
      opts[:style] = 'display:none;' unless selected.id == plan.id

      content_tag(:div, opts) do
        render 'plans/widget', :plan => plan
      end
    end.join.html_safe
  end


end
