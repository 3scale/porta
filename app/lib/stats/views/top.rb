
module Stats
  module Views
    module Top
      private

      include ::ThreeScale::MethodTracing

      def top(name, options)
        options = options.symbolize_keys
        options.assert_valid_keys(:period, :since, :metric, :metric_name, :limit, :timezone, :skip_change)
        options.assert_required_keys(:period)

        period = options[:period]
        since = extract_since(options)
        metric = extract_metric(options)

        singular_name = name.to_s.singularize

        data = storage.ordered_hash(since, period,
          :from  => [:stats, source, name],
          :by    => [:stats, source, {singular_name => :*}, metric ],
          :limit => options[:limit] || 10,
          :order => :desc)


        if block_given?
          data.reject!{|id, value| value.blank?}
          data.map { |id, value| yield(id, value) }.compact
        else
          data
        end
      end

      add_three_scale_method_tracer :top
    end
  end
end
