module AsJsonLogger
  def as_json
    to_s
  end
end

ActiveSupport::Logger.prepend(AsJsonLogger)
