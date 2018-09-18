module ThreeScale::Warnings
  # all methods are class methods
  extend self

  class DeprecationError < StandardError
    attr_reader :backtrace, :object, :method, :args

    def initialize(method, object, *args)
      @object, @method, @args = object, method, args
      msg = "Called deprecated method #{method}"
      msg << "(#{args.join(", ")})" if args
      msg << "on #{object}" if object
      super(msg)
    end

    def set_backtrace= trace
      @backtrace = trace
    end
  end

  module ControllerExtension
    # 'expected' should be one of [ provider, buyer, master ]
    #
    def notify_about_wrong_domain(url, expected, options = {})
      # if there is no referer there is not a link leading there and
      # we don't care about it
      return unless request.referer

      options[:error_message] = "URL '#{url}' is #{expected} only."
      options[:error_class] = 'ThreeScale::Warnings::WrongDomain'

      Rails.logger.info("ThreeScale::Warnings::WrongDomain: URL '#{url}' is #{expected} only.")
    end

    def deprecated_api(deprecation_message)
      logger.warn deprecation_message
    end
  end

  def deprecated_method(method_name, object = nil, args = nil, callstack = caller)
    exception = DeprecationError.new(method_name, object, args)
    exception.set_backtrace = callstack

    notify_developers(exception, :error_class => 'ThreeScale::Warnings::DeprecatedMethod')
  end

  def deprecated_method!(method_name, callstack = caller)
    exception = DeprecationError.new(self, method_name)
    exception.set_backtrace = callstack

    notify_developers!(exception, :error_class => 'ThreeScale::Warnings::DeprecatedMethod')
  end

  protected

  def notify_developers!(exception, options = {})
    if Rails.env.development? || Rails.env.test?
      raise exception
    else
      notify_developers(exception, options)
    end
  end

  def notify_developers(exception, options = {})
    if exception.object
      options[:parameters] = { :object => exception.object }
    end

    System::ErrorReporting.report_error(exception, options)
  end

end
