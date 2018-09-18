module BackendClient
  class Base

    private

    def preload_cinstances(application_ids)
      account.provided_cinstances.find_all_by_application_id(application_ids).index_by(&:application_id)
    end

    def parse_timestamp(input)
      # TODO: Convert to current timezone
      Time.use_zone('UTC') { Time.zone.parse(input.to_s) }
    end

    def self.http_methods *methods, &block
      methods.flatten.each do |method|
        define_method(method) do |*args|
          path, params = args
          instance_exec(method, path, (params || {}), &block) if block_given?
        end
      end
    end

  end
end
