case RUBY_VERSION
when '2.3.0'
  # backport https://github.com/ruby/ruby/commit/15960b37e82ba60455c480b1c23e1567255d3e05
  require 'ostruct'
  OpenStruct.singleton_class.class_eval do
    alias allocate new
  end
end
