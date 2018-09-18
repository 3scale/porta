module Provider::Admin::CMS::DashboardHelper

  def url_admin_service_application_plans
    if current_account_first_service
      admin_service_application_plans_path(current_account_first_service)
    else
      '#'
    end
  end

  def url_edit_service_integration
    if current_account_first_service
      edit_admin_service_integration_path(current_account_first_service)
    else
      '#'
    end
  end

  def url_service_stats
    if current_account_first_service
      admin_service_stats_usage_path(current_account_first_service)
    else
      '#'
    end
  end

  def panel_widget(title, intro, url = '', &block)
    @done_steps = []
    @prev_done = false

    def link_step(title, url = '#', step = nil, target = '_self')
      done = step.present? ? current_account.go_live_state.steps.send(step.to_sym) : false
      @done_steps << done

      klass = if done
                "done"
              elsif (@prev_done || @done_steps.size) == 1
                "next-step"
              else
                ""
              end

      @prev_done = done

      %{
        <li id="#{step}" class="to-do #{klass}">
          <i class="fa-li fa fa-circle#{done ? '' : '-o'}"></i>
          <a class="todo" href="#{url}" target="#{target}"> #{title} </a>
          #{ help_bubble do
            I18n.t("provider.admin.dashboards.show.integration_steps.#{step}_help_html").html_safe
          end
          }
        </li>
      }.html_safe
    end

    html_block = capture(&block) if block_given?

    %{
    <li>
      <h2>
        #{title}
      </h2>
      <div class="details">
        <p>
          #{intro}
        </p>
        <ul class="fa-ul">
          #{html_block if block_given?}
        </ul>
      </div>
    </li>
   }.html_safe
  end


  private

  def current_account_first_service
    services = current_account.accessible_services
    if services.default
      services.default
    elsif services.first
      services.first
    end
  end

  def icon_circles(done_steps)
    html = ""
    done_steps.each do |step|
      html += "<i class='icon-circle#{step ? '' : '-blank'}'></i>".html_safe
    end
    html
  end
end



