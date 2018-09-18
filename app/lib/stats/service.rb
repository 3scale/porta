
module Stats
  class Service < Base
    include ::ThreeScale::MethodTracing

    include Views::Usage
    include Views::Top
    include Views::Total
    include Views::ActiveClients

    def top_clients(options)
      # TODO: optimize cinstance lookup
      since = extract_since(options) # normalizes since to the beginning of period
      range, granularity, metric = extract_range_and_granularity_and_metric(options.merge(since: since))
      data = top(:cinstances, options) do |id, value|
        cinstance = find_cinstance(id)

        if cinstance && cinstance.user_account
          {
            :name     => cinstance.name,
            :id       => cinstance.id,
            :value    => value,
            :account => {
              :id    => cinstance.user_account.id,
              :name  => cinstance.user_account.org_name
              },
            :plan => {
              :id      => cinstance.plan.id,
              :name    => cinstance.plan.name
            }
          }
        # Usage data per app cinstance should not be here.
        # :usage  => Stats::Client.new(cinstance).usage(options)}
        end
      end
      {
        :applications => data,
        metric.class.name.underscore.to_sym => detail(metric),
        :period => {
          :name  => options[:period],
          :since => range.begin,
          :until => range.end
        }
      }
      #TODO: test this
    rescue ActiveRecord::RecordNotFound # some cinstances are not being found
      { }
    end

    add_three_scale_method_tracer :top_clients

    def top_countries(options)
      # TODO: optimize country lookup

      top(:countries, options) do |id, value|
        country = Country.find_by_code!(id)

        {:country_name => country.name,
         :country_code => country.code,
         :value        => value}
      end
    end

    def find_cinstance(id)
      source.first.cinstances.find_by_application_id(id)
    end
    add_three_scale_method_tracer :find_cinstance
  end
end
