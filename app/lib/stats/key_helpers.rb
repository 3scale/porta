
module Stats
  module KeyHelpers
    include ::ThreeScale::MethodTracing

    # Convert any value into storage key.
    def key_for(*args)
      if args.size > 1
        key_for(args)
      else
        case object = args.first
        # HACK: - should polymorphically take the name
        when ApplicationPlan
          key_for('plan' => object)
        when ActiveRecord::Base
          key_for(object.class.name.underscore => object)
        when ResponseCode
          key_for( response_code: object.code )
        when Hash
          object.map { |key, value| encode_pair(key, value) }.join('/')
        when Array
          object.map { |part| key_for(part) }.join('/')
        else
          encode_key(object)
        end
      end
    end
    add_three_scale_method_tracer :key_for

    def encode_pair(key, value)
      key = encode_key(key)
      value = encode_key(value)

      if key == 'service'
        "{#{key}:#{backend_id(value.to_i)}}"
      else
        "#{key}:#{value}"
      end
    end

    def backend_id(service_id)
      @__services ||= {}
      @__services[service_id] ||= ::Service.find(service_id).backend_id
    end

    # returns stringifyed id for AR objects
    # arrays NEVER arrive here (see Recursive key_for)
    # num => num
    # string => string
    def encode_key(key)
      key.to_param.to_s.gsub(/\s/, '+')
    end

    def decode_key(key)
      key.tr('+', ' ')
    end
  end
end
