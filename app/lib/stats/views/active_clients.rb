module Stats
  module Views
    module ActiveClients

      def active_clients_progress(options)
        options = options.symbolize_keys
        options.assert_valid_keys(:since, :until, :range, :timezone)
        options[:granularity] ||= :day

        range = extract_range(options)
        cinstances = source.last.cinstances

        current_count  = cinstances.live_at(range).count
        previous_count = cinstances.live_at(range.previous).count

        # TODO: optimize this, because it's very inefficient
        progress = range.each(options[:granularity]).map do |interval|
          cinstances.live_at(interval).count
        end

        {:total    => current_count,
         :change   => current_count.percentage_change_from(previous_count),
         :progress => progress}
      end

      private

      # TODO: this code is used almost everywhere. Should be DRY!
      def extract_range(options)
        (options[:range] || (options[:since]..options[:until]))
          .to_time_range.round(options[:granularity]).utc
      end
    end
  end
end
