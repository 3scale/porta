# frozen_string_literal: true

class BillingSummary

  delegate :redis, to: :System

  def initialize(id)
    @id = id
  end

  attr_reader :id

  def store(account_id, billing_result)
    redis.zadd(summary_key, score_from_result(billing_result), account_id.to_s)
  end

  def unstore
    redis.del(summary_key)
  end

  def build_result(account_id, billing_date)
    result = Finance::BillingStrategy::Results.new(billing_date)
    result[account_id] = to_hash
    result
  end

  def to_hash
    skip_count = fetch_skip_count
    errors = fetch_errors

    {
      success: errors.empty?,
      skip: skip_count.positive?,
      errors: errors.map(&:to_i)
    }
  end

  protected

  SUCCESS_SCORE = 1
  SKIP_SCORE = 0
  ERROR_SCORE = -1
  private_constant :SUCCESS_SCORE, :SKIP_SCORE, :ERROR_SCORE

  def summary_key
    @summary_key ||= "billing-summary-#{id}"
  end

  def score_from_result(billing_result)
    if billing_result[:success]
      SUCCESS_SCORE
    elsif billing_result[:errors].presence
      ERROR_SCORE
    else
      SKIP_SCORE
    end
  end

  def fetch_skip_count
    limit = SKIP_SCORE.to_s
    redis.zcount(summary_key, limit, limit)
  end

  def fetch_errors
    limit = ERROR_SCORE.to_s
    redis.zrangebyscore(summary_key, limit, limit)
  end
end
