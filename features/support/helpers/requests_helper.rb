# frozen_string_literal: true

# License:
# Copyright (c) 2011-2017 GitLab B.V.
#
# With regard to the GitLab Software:
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# For all third party components incorporated into the GitLab Software, those
# components are licensed under the original license provided by the owner of the
# applicable component.

# Extracted from: https://gitlab.com/gitlab-org/gitlab-ce/blob/4f6620a5ae00383a015379f95408ed7f1be1bdbb/spec/support/helpers/wait_for_requests.rb
module WaitForRequests
  extend self

  # This is inspired by http://www.salsify.com/blog/engineering/tearing-capybara-ajax-tests
  def block_and_wait_for_requests_complete
    block_requests { wait_for_all_requests }
  end

  # Block all requests inside block with 503 response
  def block_requests
    Gitlab::Testing::RequestBlockerMiddleware.block_requests!
    yield
  ensure
    Gitlab::Testing::RequestBlockerMiddleware.allow_requests!
  end

  # Slow down requests inside block by injecting `sleep 0.2` before each response
  def slow_requests
    Gitlab::Testing::RequestBlockerMiddleware.slow_requests!
    yield
  ensure
    Gitlab::Testing::RequestBlockerMiddleware.allow_requests!
  end

  # Wait for client-side AJAX requests
  def wait_for_requests
    wait_for('JS requests complete', max_wait_time: 2 * Capybara.default_max_wait_time) do
      finished_all_js_requests?
    end
  end

  # Wait for active Rack requests and client-side AJAX requests
  def wait_for_all_requests
    wait_for('pending requests complete') do
      finished_all_rack_reqiests? &&
        finished_all_js_requests?
    end
  end

  private

  def finished_all_rack_reqiests?
    Gitlab::Testing::RequestBlockerMiddleware.num_active_requests.zero?
  end

  def finished_all_js_requests?
    return true unless javascript_test?

    finished_all_ajax_requests? &&
      finished_all_vue_resource_requests?
  end

  # Waits until the passed block returns true
  def wait_for(condition_name, max_wait_time: Capybara.default_max_wait_time, polling_interval: 0.01)
    wait_until = Time.now + max_wait_time.seconds
    loop do
      break if yield

      if Time.now > wait_until
        raise "Condition not met: #{condition_name}"
      else
        sleep(polling_interval)
      end
    end
  end

  def finished_all_vue_resource_requests?
    Capybara.page.evaluate_script('window.activeVueResources || 0').zero?
  end

  def finished_all_ajax_requests?
    return true if Capybara.page.evaluate_script('typeof jQuery === "undefined"')

    Capybara.page.evaluate_script('jQuery.active').zero?
  end

  def javascript_test?
    Capybara.current_driver == Capybara.javascript_driver
  end
end


# Extracted from: https://gitlab.com/gitlab-org/gitlab-ce/blob/4f6620a5ae00383a015379f95408ed7f1be1bdbb/spec/support/helpers/inspect_requests.rb
module InspectRequests

  def inspect_requests(inject_headers: {})
    Gitlab::Testing::RequestInspectorMiddleware.log_requests!(inject_headers)

    yield

    wait_for_all_requests
    Gitlab::Testing::RequestInspectorMiddleware.requests
  ensure
    Gitlab::Testing::RequestInspectorMiddleware.stop_logging!
  end
end

World(WaitForRequests)
World(InspectRequests)
