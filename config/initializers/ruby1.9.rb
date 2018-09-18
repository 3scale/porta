if RUBY_VERSION >= '1.9'
  # Ruby 1.9 compatability

else

  # Ruby 1.8 compatability
  class KeyError < IndexError; end unless defined?(KeyError)

  # Fail properly when calling #id on non AR objects
  Object.send(:undef_method, :id) rescue NameError
end
