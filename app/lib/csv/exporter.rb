# frozen_string_literal: true

class Csv::Exporter
  BOM = "\uFEFF"

  def initialize(account, params = {})
    @account = account
    @period = params[:period]
    @range = case @period
             when 'today'      then Time.now.beginning_of_day..Time.now.end_of_day
             when 'this_week'  then Time.now.beginning_of_week..Time.now.end_of_week
             when 'this_month' then Time.now.beginning_of_month..Time.now.end_of_month
             when 'this_year'  then Time.now.beginning_of_year..Time.now.end_of_year
             when 'last_year'  then 1.year.ago.beginning_of_year..1.year.ago.end_of_year
             end

    # TODO: delegate to subclasses and don't use the generic term
    @target = params[:data] || 'objects'
  end

  def to_csv
    csv = generate
    csv
  end

  def output_encoding
    Encoding.default_external
  end

  def csv_options
    {}
  end

  def send_options
    {
      :type => 'text/csv; header=present',
      :disposition => "attachment; filename=#{filename}"
    }
  end

  def to_send_data
    [ to_csv, send_options ]
  end

  def generate
    ::CSV.generate(csv_options) do |csv|
      yield csv
    end
  end

  def filename
    "3Scale-#{Time.zone.now.to_i}-#{@target.humanize}.csv"
  end

  protected

  def header
    period = if @range
               "period from #{@range.begin.to_date} to ##{@range.end.to_date}"
             else
               "All time (generated #{Time.zone.now})"
             end

    ["#{@account.org_name}/#{@account.domain} - All #{@target.try!(:humanize)} / #{period}"]
  end

end
