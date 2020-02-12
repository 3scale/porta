class HashOrActionParameter
  class << self
    # Load our serialized data, that can be: ActionController::Parameters or a Hash
    def load(value)
      return unless value
      if value.match(/!ruby\/object:ActionController::Parameters/) || value.starts_with?('---')
        object = YAML.load(value)
        object.try(:to_unsafe_hash) || object.to_h
      else
        JSON.parse(value.gsub(/:([a-zA-z]+)/,'"\\1"').gsub('=>', ': '))
      end.symbolize_keys
    end

    def dump(data)
      data.to_s
    end
  end
end
