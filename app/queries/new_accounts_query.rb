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
    method_name = "#{System::Database.adapter}_query".to_sym
    date_format = granularity_to_date_format(granularity)
    method(method_name).call(range, date_format)
  end

  def mysql_query(range, date_format)
    mysql_subquery(range, date_format)
  end

  def postgres_query(range, date_format)
    sql = "SELECT 1 FROM pg_timezone_names WHERE name = #{connection.quote(time_zone_name)};"
    # TODO: Cache the time zones known by the database
    timezone = connection.select_value(sql).to_s == '1' ? time_zone_name : time_zone.formatted_offset

    mysql_subquery range, date_format, timezone: timezone
  end

  def oracle_query(range, date_format)
    oracle_subquery range, date_format, timezone: time_zone_name
  # FIXME: Rescuing from ActiveRecord::StatementInvalid is not recommended. See https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html (Exception handling and rolling back)
  rescue ActiveRecord::StatementInvalid
    oracle_subquery range, date_format, timezone: time_zone.formatted_offset
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

  def mysql_subquery(range, date_format, timezone: Time.zone.tzinfo.name)
    account.buyer_accounts
        .where.has { sift(:date, sift(:in_timezone, created_at, name: timezone)).in(range) }
        .grouping { sift(:date_format, sift(:in_timezone, created_at, name: timezone), date_format).to_sql }
        .count(:id)
  end

  def oracle_subquery(range, date_format, timezone: Time.zone.tzinfo.name)
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

  def time_zone
    Time.zone
  end

  def time_zone_name
    time_zone.tzinfo.name
  end

  delegate :connection, to: 'ActiveRecord::Base'
end
