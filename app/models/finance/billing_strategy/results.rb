# frozen_string_literal: true

# Gotta catch'em all!
#
class Finance::BillingStrategy::Results
  attr_reader :period

  def initialize(period)
    @period = period
    @providers = {}
  end

  def start(billing_strategy)
    @providers[billing_strategy.provider.id] = { errors: [], success: false }
  rescue
    Rails.logger.error('Failed to log a billing start')
    raise if Rails.env.test?
  end

  def success(billing_strategy)
    @providers[billing_strategy.provider.id][:success] = true
    @providers[billing_strategy.provider.id][:errors] = billing_strategy.failed_buyers
  rescue
    Rails.logger.error('Failed to log a billing success')
    raise if Rails.env.test?
  end

  def skip(billing_strategy)
    @providers[billing_strategy.provider.id] = { skip: true, errors: [] }
  end

  def failure(billing_strategy)
    status = @providers[billing_strategy.provider.id] ||= {}
    status[:success] = false
    status[:errors] = billing_strategy.failed_buyers
  rescue
    Rails.logger.error('Failed to log a billing failure')
    raise if Rails.env.test?
  end

  delegate :[], :[]=, to: :@providers

  #--- fetching results methods

  def with_errors
    @providers.select { |k,v| v[:errors].present? }
  end

  def skipped
    @providers.select { |k,v| v[:skip] }
  end

  def providers_count
    @providers.size
  rescue
    -1
  end

  def providers_failed_count
    @providers.inject(0) do |sum, provider|
      id, status = provider
      status[:success] ? sum : sum + 1
    end
  rescue
    raise if Rails.env.test?
    -1
  end

  def buyers_failed_count
    @providers.inject(0) do |sum, provider|
      id, status = provider
      sum + status[:errors].size
    end
  rescue
    raise if Rails.env.test?
    -1
  end

  def inspect_all_things
    @providers.inspect
  rescue
    '# inspector failed'
  end

  def successful?
    @providers.all? do |provider_id,status|
      (status[:success] || status[:skip]) && status[:errors].empty?
    end
  rescue
    raise if Rails.env.test?
    false
  end

end
