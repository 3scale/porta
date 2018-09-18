# This provides the endpoint for load balancer checking, to see if the machine is responding and
# if it has reasonable response time.
#
# Normaly, just a static file check.txt in public is used, but we actually need the full stack to
# be executed, because there were some failures in the past not detected by the static file check.
class ChecksController < ApplicationController
  def check
    render :plain => 'ok', :status => :ok
  end

  CheckError = Class.new(StandardError)

  def error
    raise CheckError, 'this is manually triggered error, no worries'
  end
end
