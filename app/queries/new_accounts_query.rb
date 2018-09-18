# frozen_string_literal: true

class NewAccountsQuery
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def within_timeframe(range:, granularity: :day)
    result_date_format = granularity_to_date_format(granularity)
    groups = query(range, granularity: granularity)

    range.map do |range_date|
      range_date_in_format = range_date.strftime(result_date_format)

      [range_date_in_format, groups.fetch(range_date_in_format, 0)]
    end.to_h
  end

  def query(range, granularity:)
    method(System::Database.oracle? ? :oracle_query : :mysql_query)
        .call(range, granularity_to_date_format(granularity))
  end

  def oracle_query(range, date_format)
    time_zone = Time.zone

    begin
      oracle_subquery(range, date_format, time_zone.tzinfo.name)
      # Oracle can't rescue invalid time zone conversion
    rescue ActiveRecord::StatementInvalid
      oracle_subquery(range, date_format, time_zone.formatted_offset)
    end
  end

  def oracle_subquery(range, date_format, timezone)
    query = account.buyer_accounts.where.has do
      sift(:date, sift(:in_timezone, created_at, name: timezone)).in(range)
    end

    query = query.selecting do
      [
        id,
        sift(:date_format, sift(:in_timezone, created_at, name: timezone), date_format).as('dategrouping')
      ]
    end

    Account.from(query, 'subquery').group('dategrouping').count('subquery.id')
  end

  def mysql_query(range, date_format)
    account.buyer_accounts
        .where.has { sift(:date, sift(:in_timezone, created_at)).in(range) }
        .grouping { sift(:date_format, sift(:in_timezone, created_at), date_format).to_sql }
        .count(:id)
  end

  private

  def granularity_to_date_format(granularity)
    case granularity
    when :year
      '%Y'
    when :month
      '%Y-%m'
    when :day
      '%Y-%m-%d'
    when :hour
      '%Y-%m-%dT%H'
    else
      raise "Unknown granularity #{granularity.inspect}"
    end
  end
end
