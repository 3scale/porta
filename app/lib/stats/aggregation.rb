module Stats
  module Aggregation
    @@rules = Rules.new
    mattr_reader :rules

    # Define aggregation rules in given block.
    #
    # Use like this:
    #
    #   Aggregation.define do |rules|
    #     rules.add :service, :granularity => 1.hour
    #     # ...
    #   end
    #
    def self.define
      yield rules
    end

    # Run all defined aggregations with the given transactions.
    def self.aggregate(transaction)
      rules.aggregate(transaction)
    end

    # Makes sure that 1.day is the same as :day.
    def self.normalize_granularity(granularity)
      case granularity
      when 1.week                                   then :week
      when 1.day                                    then :day
      when 1.hour                                   then :hour
      when 1.minute                                 then :minute
      when 1.second                                 then :second
      when Symbol, Integer, ActiveSupport::Duration then granularity
      when /\d+/                                    then granularity.to_i
      else granularity.to_sym
      end
    end
  end
end

Stats::Aggregation.define do |rules|
  rules.add :service, :granularity => :eternity
  rules.add :service, :granularity => :month
  rules.add :service, :granularity => :week
  rules.add :service, :granularity => :day
  rules.add :service, :granularity => :hour

  rules.add :service, :cinstance, :granularity => :eternity
  rules.add :service, :cinstance, :granularity => :year
  rules.add :service, :cinstance, :granularity => :month
  rules.add :service, :cinstance, :granularity => :week
  rules.add :service, :cinstance, :granularity => :day
  rules.add :service, :cinstance, :granularity => :hour
  rules.add :service, :cinstance, :granularity => :minute, :expires_in => 1.minute
end
