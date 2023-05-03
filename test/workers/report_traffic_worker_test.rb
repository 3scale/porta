require 'test_helper'

class ReportTrafficWorkerTest < ActiveSupport::TestCase
  setup do
    @master = master_account

    @account    = FactoryBot.create(:simple_provider)
    @service    = Service.create!(account: @account, name: 'service')
    @cinstance  = Cinstance.create!(plan: @master.application_plans.first!, user_account: @account)
    @metric     = :hits

    ReportTrafficWorker.stubs(:enabled?).returns(true)

    @request  = stub({ fullpath: "test/foo/bar", method: "GET", remote_ip: "127.0.0.1", headers: { "HTTP_FOO" => "bar", "FOO" => "bar" } })
    @response = stub({ status: 200, body: "ok" })
  end

  test "enqueue" do
    freeze_time do
      assert ReportTrafficWorker.enqueue(@account, @metric, @request, @response)
      args = [
        @account.id,
        @metric.to_s,
        {
          "path"      => @request.fullpath,
          "method"    => @request.method,
          "remote_ip" => @request.remote_ip,
          "headers"   => { "HTTP_FOO" => "bar" },
        },
        { "code" => 200, "length" => 2, "body" => "discarded" },
        Time.now.to_i
      ]

      assert_equal args, ReportTrafficWorker.jobs.first["args"]
      assert_equal 1, ReportTrafficWorker.jobs.size
    end
  end

  test "enqueue sends different response body depending on response code" do
    freeze_time do
      failed_response = stub(status: 422, body: "invalid parameters")
      assert ReportTrafficWorker.enqueue(@account, @metric, @request, failed_response)

      args = [
        @account.id,
        @metric.to_s,
        {
          "path"      => @request.fullpath,
          "method"    => @request.method,
          "remote_ip" => @request.remote_ip,
          "headers"   => { "HTTP_FOO" => "bar" },
        },
        { "code" => 422, "length" => 18, "body" => "invalid parameters" },
        Time.now.to_i
      ]

      assert_equal args, ReportTrafficWorker.jobs.first["args"]
      assert_equal 1, ReportTrafficWorker.jobs.size
    end
  end

  test "perform" do
    freeze_time do
      response_attrs = { code: @response.status, length: @response.body.size }
      request_attrs  = {
        path:      @request.fullpath,
        method:    @request.method,
        remote_ip: @request.remote_ip,
        headers:   { "HTTP_FOO" => "bar" },
      }
      transactions = [{
        app_id: @cinstance.application_id,
        usage:  { @metric => 1 },
        log: {
          request:  request_attrs,
          response: response_attrs,
          code: 200,
        },
        timestamp: Time.now.utc.to_s
      }]

      master_service = @master.default_service
      ThreeScale::Client.any_instance.expects(:report)
        .with(transactions: transactions, service_id: master_service.id, service_token: master_service.service_token).returns(true)

      assert ReportTrafficWorker.new.perform(@account.id, @metric, request_attrs, response_attrs)

      assert_equal 0, ReportTrafficWorker.jobs.size
    end
  end

  test 'logs the response in case of server error' do
    server_response = stub({ code: 500 })
    ThreeScale::Client.any_instance.expects(:report).raises(ThreeScale::ServerError, server_response)

    response_attrs = { code: @response.status, length: @response.body.size }
    request_attrs  = {
      path:      @request.fullpath,
      method:    @request.method,
      remote_ip: @request.remote_ip,
      headers:   { "HTTP_FOO" => "bar" },
    }

    assert_raises(ReportTrafficWorker::ReportTrafficError) do
      ReportTrafficWorker.new.perform(@account.id, @metric, request_attrs, response_attrs)
    end
  end
end
