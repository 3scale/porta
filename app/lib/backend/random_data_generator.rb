# frozen_string_literal: true

begin
  require '3scale/client'
rescue LoadError
  Rails.logger.debug('Cannot use Backend::RandomDataGenerator')
end

module Backend
  class RandomDataGenerator
    def self.generate(options)
      options.assert_valid_keys(:cinstance_id, :since, :until, :metric, :min, :max, :frequency, :http)

      cinstance = Cinstance.find(options[:cinstance_id])
      metric    = find_metric(cinstance, options[:metric])

      time_range  = (options[:since] || cinstance.created_at)..(options[:until] || Time.zone.now)
      time_range  = time_range.to_time_range
      value_range = options[:min].to_i..(options[:max] || 1000).to_i
      frequency   = (options[:frequency] || 0.01).to_f
      times       = random_times_in(time_range, frequency)

      hit_method  = options[:http] ? method(:http_hit) : method(:hit)

      times.each do |time|
        value = random_value_in(value_range)
        hit_method.call(cinstance, time, metric, value)
        puts "Generating #{value} #{metric.name.pluralize} at #{time}"
      end
    end

    def self.http_hit(cinstance, time, metric, value)
      return unless enabled?
      if value > 0
        service = cinstance.service
        transactions = {
          app_id:    cinstance.application_id,
          usage:     { metric.name => value },
          log:       log_example,
          timestamp: time,
        }

        invalid = invalid_transactions(cinstance, time, metric, value)
        client = ThreeScale::Client.new(System::Application.config.backend_client.merge(
                                         provider_key: service.account.api_key))
        client.report(transactions)
        client.report(invalid)
      end
    end

    def self.invalid_transactions(cinstance, time, metric, value)
      [
        {
          app_id:    cinstance.application_id, # invalid metric
          usage:     { "unknown-metric-foo-bar" => value },
          timestamp: time,
       },
        {
          app_id:     "unknown-application_id", # invalid app_id
          usage:     { metric.name => value },
          timestamp: time,
        }
      ]
    end

    # @param cinstance [Cinstance]
    # @param time [Time]
    # @param metric [Metric]
    # @param value [Integer]
    def self.hit(cinstance, time, metric, value)
      return unless enabled?
      if value > 0
        Transaction.report!(:cinstance  => cinstance,
                            :service_id => cinstance.service.id,
                            :usage      => {metric.name => value},
                            :log        => log_example,
                            :created_at => time,
                            :confirmed  => true)
      end
    end

    private

    def self.enabled?
      ThreeScale.const_defined?(:Client)
    end

    def self.log_example
      codes = [200, 403, 409, 503, 500]
      code  = codes.sample
      {
        request:  { path: "", method: "GET", headers: {} },
        response: { code: code, length: rand(100) },
        code:     code,
      }
    end

    def self.random_times_in(range, frequency)
      results = []
      (range.length * frequency).round.times do
        results << random_value_in(range)
      end

      results.sort
    end

    def self.random_value_in(range)
      range.begin + rand(range.end - range.begin + 1)
    end

    def self.find_metric(cinstance, id_or_name)
      metrics = cinstance.service.metrics

      case id_or_name
      when nil
        metrics.hits
      when String
        metrics.where(system_name: id_or_name).first!
      when Numeric, /^\d+$/
        metrics.find(id_or_name)
      when Metric
        id_or_name
      else
        raise "unknown metric identifier: #{id_or_name}"
      end
    end
  end
end
