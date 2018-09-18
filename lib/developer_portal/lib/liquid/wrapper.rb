class Liquid::Wrapper

  def initialize(current_account = nil, web_params = {})
    @current_account = current_account
    @selected_ids = web_params[:plans] || []
  end

  def wrap_service(service)
    subscribed = if @current_account
                   !!service.service_contract_of(@current_account)
                 else
                    false
                  end

    Liquid::Drops::Service.new(service, { :subscribed =>  subscribed })
  end

  def wrap_plan(plan)
    opts = {
      :bought   => bought?(plan),
      :selected => selected?(plan)
    }

    case plan
    when ::AccountPlan then Liquid::Drops::AccountPlan.new(plan, opts)
    when ::ServicePlan then Liquid::Drops::ServicePlan.new(plan, opts)
    when ::ApplicationPlan then Liquid::Drops::ApplicationPlan.new(plan, opts)
    end
  end

  def wrap_plans(plans)
    plans.map { |plan| wrap_plan(plan) }
  end

  private

  def selected?(plan)
    @selected_ids.include?(plan.id) || @selected_ids.include?(plan.id.to_s)
  end

  def bought?(plan)
    @current_account.bought?(plan) if @current_account
  end

end
