module ContractHelper



  def width_me(plans)
    case plans
    when 1
      return '67%'
    when 2
      return '37%'
    else
      return nil
    end
  end

  # Quick and dirty helper to render plan name cell in plans table.
  def plan_header_cell(plan, index, plan_size)
    classes = []
    classes << 'plan_name' << 'thhead'
    classes << 'thead_first' if index == 0
    classes << 'thead_last' if (index + 1) == plan_size
    classes << 'selected' if plan.bought_by?(current_account)

    content_tag('td', :class => classes.join(' ')) do
      content_tag('h3', h(plan.name))
    end
  end
end
