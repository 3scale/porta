# frozen_string_literal: true

module Stats
  class BackendApi < Base
    include Views::Usage

    def initialize(*sources)
      source = sources.first
      super(source)
      @services = source.services.map(&Stats::Service.method(:new))
    end

    attr_reader :services

    def usage(options)
      results = services.map { |service| service.usage(options) }
      results_values = ->(attr) { results.map { |result| result[attr] } }

      result = results.first.slice(:metric, :period)

      total = results_values.call(:total).sum
      result[:total] = total
      result[:values] = results_values.call(:values).transpose.map(&:sum)

      return result if options.fetch(:skip_change, true)

      previous_total = results_values.call(:previous_total).sum
      result[:previous_total] = previous_total
      result[:change] = total.percentage_change_from(previous_total)

      result
    end
  end
end
