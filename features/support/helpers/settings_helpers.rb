module SettingsHelpers
  def underscore_spaces(name)
    name.gsub(/\s+/, '_').underscore
  end

  def typecast_value(value)
    case value
    when 'true'
      true
    when 'false'
      false
    else
      value
    end
  end
end

World(SettingsHelpers)
