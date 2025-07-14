# frozen_string_literal: true

require 'test_helper'

class Finance::InvoiceDownloadTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = FactoryBot.create(:invoice, state: :finalized)
  end

  teardown do
    @invoice.pdf.clear
    @invoice.save
  end

  test "can download only with the signed path" do
    path, query = @invoice.pdf.expiring_url.split("?", 2)
    invoice2 = FactoryBot.create(:invoice, state: :finalized)
    wrong_path = invoice2.pdf.expiring_url.split("?", 2).first

    get "#{wrong_path}?#{query}"
    assert_response :forbidden

    get "#{path}?#{query}"
    assert_response :ok
  ensure
    invoice2&.pdf&.clear
    invoice2&.save
  end

  test "can download only with correct signing parameters" do
    get @invoice.pdf.url
    assert_response :forbidden

    path, query = @invoice.pdf.expiring_url.split("?", 2)
    params = Rack::Utils.parse_query(query)

    params_without_expiration = params.reject { _1 == "3scale-Expires" }
    get "#{path}?#{params_without_expiration.to_param}"
    assert_response :forbidden

    params_without_signature = params.reject { _1 == "3scale-Signature" }
    get "#{path}?#{params_without_signature.to_param}"
    assert_response :forbidden

    year_now = Time.now.utc.year
    params_with_altered_time = params.dup
    params_with_altered_time["3scale-Expires"] = params["3scale-Expires"].sub(year_now.to_s, (year_now + 1).to_s)
    get "#{path}?#{params_with_altered_time.to_param}"
    assert_response :forbidden

    params_with_altered_time["3scale-Expires"] = "invalidtimestamp"
    get "#{path}?#{params_with_altered_time.to_param}"
    assert_response :forbidden

    params_with_altered_sig = params.dup
    params_with_altered_sig["3scale-Signature"] = params["3scale-Signature"].sub(/[^a]/, "a")
    get "#{path}?#{params_with_altered_sig.to_param}"
    assert_response :forbidden

    params_with_altered_sig["3scale-Signature"][2] = "-" # invalid base64
    get "#{path}?#{params_with_altered_sig.to_param}"
    assert_response :forbidden

    get "#{path}?#{params.to_param}"
    assert_response :ok
    assert_equal @invoice.pdf.size, response.body.size

    travel_to(Time.now + 3602) do
      get "#{path}?#{params.to_param}"
      assert_response :forbidden
    end
  end

  test "no cheating with path parsing" do
    path, query = @invoice.pdf.expiring_url.split("?", 2)

    # dunno how to test backslashes, null char and missing leading slash in path, use telnet
    # telnet provider-admin.3scale.localhost 3000
    # GET /system/provider-name/invoices/1/pdfs/original/invoice-october-2024.pdf HTTP/1.0
    # Host: provider-admin.3scale.localhost:3000
    evil_paths = %w[/./system/ /system/x/../ /../system/ /system%2f /system%2fx/..%2f /system/x/%2e%2e/]

    evil_paths.all? do |replacement|
      evil_path = path.sub %r{/system/}, replacement
      get "#{evil_path}?#{query}"
      assert_response :forbidden
    end

    other_evils = %w[/system%5c /syst%00em/]
    other_evils.each do |replacement|
      evil_path = path.sub %r{/system/}, "/system%5c"
      assert_raise(ActionController::RoutingError) do
        get "#{evil_path}?#{query}"
      end
    end
  end
end
