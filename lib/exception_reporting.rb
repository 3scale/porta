module Kernel
  # Call the given block, and if it raises an exception, log it, notify airbrake and supress it.
  def report_and_supress_exceptions
    if Rails.env.development? || Rails.env.test?
      yield
    else
      begin
        yield
      rescue Exception => exception
        message = "#{exception.class.name}: #{exception.message}\n"
        message << exception.backtrace.map { |line| "\t#{line}" }.join("\n")

        System::ErrorReporting.report_error(exception)
      end
    end
  end
end
