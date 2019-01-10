module PlanHelpers

  def create_plan(type, options)
    options[:cost] ||= 0

    issuer = options[:issuer]

    case type.to_sym
    when :application, :service
      # TODO: fix this properly, this method gets account as issuer
      # but needs service to create application or service plan
      issuer = issuer.first_service! if issuer.is_a?(Account)
    end

    master_plans = %w[base plus power1M power2M power3M power5M pro3M pro5M pro10M pro20M enterprise]
    plan = if master_plans.include? options[:name]
             FactoryBot.create(type.to_s + '_plan',
                     :name => options[:name],
                     :issuer => issuer,
                     :cost_per_month => options[:cost],
                     :system_name => options[:name])
           else
             FactoryBot.create(type.to_s + '_plan',
                     :name => options[:name],
                     :issuer => issuer,
                     :cost_per_month => options[:cost])
           end


    if flags = options[:flags]
      options[:default] = true if flags.include? 'default'
      options[:published] = true if flags.include? 'published'
    end

    if options[:default] || options[:name] == "Default"
      make_plan_default(plan)
    end

    if options[:published]
      plan.publish!
    end

    plan
  end

  def default_plan?(plan)
    plans_method = "#{plan.class.to_s.underscore}s"
    plan == plan.issuer.send(plans_method).default
  end

  def make_plan_default(plan)
    plans_method = "#{plan.class.to_s.underscore}s"
    plan.issuer.send(plans_method).default = plan
    plan.issuer.save!
  end

  def sign_up(buyer, name)
    plan = Plan.find_by_name(name)
    raise "Plan #{name} not found" unless plan
    buyer.buy!(plan)
  end

  def change_plan_permission_to_sym(mode)
    if mode =~ /directly/
      mode = :direct
    elsif mode =~ /only with credit card/
      mode = :credit_card
    elsif mode =~ /by request/
      mode = :request
    elsif mode =~ /credit card required/
      mode = :request_credit_card
    end
  end


end
