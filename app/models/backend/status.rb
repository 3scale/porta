module Backend
  class Status
    class Record < Struct.new(:usage_limit, :metric_name, :metric_id, :current_value)
      delegate :period, :period_as_range, :to => :usage_limit

      def max_value
        usage_limit.value
      end
    end

    def initialize(constant_data = {}, usage_set = nil, options = {})
      @records = (constant_data[:usage_limits] || []).map do |usage_limit|
        value = usage_set &&
                usage_set[usage_limit.period] &&
                usage_set[usage_limit.period][usage_limit.metric_id] ||
                0

        # TODO: this reverse lookup is not optimal. Not a big deal because there is
        # usually not that many metrics, but still would be nice to optimize it.
        # Perhaps by also storing hash of metric names mapped to ids in constant_data.
        # FIXME: no idea why this can be an array...
        metric_name = if constant_data[:metric_ids].respond_to?(:index) # this works for arrays and 1.8 hashes
            constant_data[:metric_ids].index(usage_limit.metric_id)
                      else # 1.9 hash
            constant_data[:metric_ids].key(usage_limit.metric_id)
        end

        Record.new(usage_limit, metric_name, usage_limit.metric_id, value)
      end

      if options[:include_plan_name]
        @plan_name = constant_data[:plan_name]
      end

      if options[:show_eternity]
        @show_eternity  = true
        @service_id     = constant_data[:service_id]
        @application_id = constant_data[:application_id]
      end
    end

    attr_reader :records, :plan_name

    def to_xml(options = {})
      xml = options[:builder] || ThreeScale::XML::Builder.new

      xml.status do |xml|
        xml.plan(plan_name) if plan_name

        if @show_eternity
          redis_url = "stats/{service:#{@service_id}}/cinstance:#{@application_id}"
          #OPTIMIZE: there's surely a ruby cond to records.uniq{|r| r.metric_id} to
          # get uniq metrics inside records
          etern_ids = []
        end

        records.each do |record|
          xml.usage(:metric => record.metric_name, :period => record.period) do |xml|
            xml.period_start(record.period_as_range.begin.to_s(:db)) unless record.period == :eternity
            xml.period_end(record.period_as_range.end.to_s(:db)) unless record.period == :eternity
            xml.current_value(record.current_value)
            xml.max_value(record.max_value)
          end

          #TODO: this needs tests!
          if @show_eternity
            unless etern_ids.include?(record.metric_id)
              etern_ids << record.metric_id

              xml.usage(:metric => record.metric_name, :period => 'eternity') do |xml|
                etern_url = redis_url + "/metric:#{record.metric_id}/eternity"
                begin
                  puts "[redis] eternity url #{etern_url}"
                  xml.current_value Backend::Transaction.storage.get(etern_url).to_i
                rescue Exception => e
                  puts "[redis FAIL] eternity url #{etern_url} -- Exception #{e.inspect}"
                  xml.current_value -1
                end
              end

            end
          end
        end
      end

      xml.to_xml
    end
  end
end

