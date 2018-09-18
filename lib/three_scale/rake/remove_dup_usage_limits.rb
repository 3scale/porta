module ThreeScale
  module Rake
    class RemoveDupUsageLimits

      PROGRESS_EACH = 10

      attr_accessor :duplicated_usage_limits

      def self.run!(provider_id = nil)
        new(provider_id).run!
      end

      def initialize(provider_id = nil)
        @provider_id = provider_id
        @duplicated_usage_limits = find_duplicateds
        @total_count = @duplicated_usage_limits.count
      end

      def find_duplicateds
        if @provider_id
          find_dups(Account.find(@provider_id).usage_limits)
        else
          find_dups(UsageLimit)
        end
      end

      def find_dups(collection)
        collection.select([:plan_id, :metric_id, :period])
              .group(:metric_id, :plan_id,:period)
              .having("count(*) > 1")
              .count(:id)
      end

      def run!
        index = 0
        progress = lambda do
          index += 1
          break unless (index % PROGRESS_EACH) == 0
          percent = (index / @total_count.to_f) * 100.0
          puts "#{percent.round(2)}% completed"
        end

        p "BEFORE => Duplicated usage_limits: #{@total_count}"

        @duplicated_usage_limits.each do |(metric, plan, period),repetitions|
          progress.call
          UsageLimit.where("metric_id = ? and plan_id = ? and period = ?",  metric, plan, period)
            .order(:updated_at).limit(repetitions -1).each(&:delete)

        end

        p "AFTER => Duplicated usage_limits: #{find_duplicateds.count}"

      end

    end
  end
end
