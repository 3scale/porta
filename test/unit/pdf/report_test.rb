require 'test_helper'

class Pdf::ReportTest < ActiveSupport::TestCase
  include TestHelpers::FakeHits

  class SimpleReportTest < ActiveSupport::TestCase
    setup do
      @account = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:simple_service, account: @account)

      @report = Pdf::Report.new(@account, @service, period: :day).generate
    end

    test 'send_notification!' do
      user = FactoryBot.create(:simple_user, role: :admin, account: @account)
      user.create_notification_preferences!(enabled_notifications: %w[daily_report])

      assert_difference ActionMailer::Base.deliveries.method(:count) do
        assert @report.send_notification!
      end
    end

    test 'notification_name' do
      @report.period = :day
      assert_equal :daily_report, @report.notification_name

      @report.period = :week
      assert_equal :weekly_report, @report.notification_name
    end

    test 'pdf file name' do
      filename = "report-#{@account.internal_domain}-#{@service.id}.pdf"
      assert_equal filename, @report.pdf_file_name

      @report.pdf.expects(:render_file).with(Rails.root.join('tmp', filename))
      assert @report.generate
    end

    test "tables without data are not generated" do
      text = PDF::Inspector::Text.analyze(File.read(@report.pdf_file_path)).strings
      assert_equal 3, text.count("No current data")
    end
  end

  class MultiPageTest < ActiveSupport::TestCase
    setup do
      @account = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:simple_service, account: @account)

      @report = Pdf::Report.new(@account, @service, period: :week)
    end

    # @note that a visual inspection is needed to properly validate the PDF
    test 'generates a multi-page report' do
      mock_values = YAML.load_file(file_fixture("report_mocks.yml").to_s).deep_symbolize_keys
      mock_values[:usage_progress_for_all_metrics][:metrics].each(&:deep_symbolize_keys!)
      mock_values.dig(:usage, :period).tap do |period|
        period[:since] = Time.parse(period[:since]).in_time_zone(period[:timezone])
        period[:until] = Time.parse(period[:until]).in_time_zone(period[:timezone])
      end
      Stats::Service.any_instance.stubs(mock_values.slice(*%i[usage_progress_for_all_metrics usage]))
      Pdf::Data.any_instance.stubs(mock_values.slice(*%i[latest_users top_users users]))

      @report.generate

      text = PDF::Inspector::Text.analyze_file(@report.pdf_file_path)
      assert_not_includes text.strings, "No current data"
      mock_values[:usage_progress_for_all_metrics][:metrics].each do |metric|
        assert_includes text.strings, metric[:name]
      end
      mock_values[:latest_users].each do |user|
        assert_includes text.strings, user[0]
        assert_includes text.strings, user[2]
      end
      mock_values[:top_users].each do |user|
        assert_includes text.strings, user[0]
      end
      mock_values[:users].each do |user|
        assert_includes text.strings, user[0]
      end
    end
  end

  test 'generate without metrics' do
    account = FactoryBot.build_stubbed(:simple_provider)
    service = FactoryBot.build_stubbed(:simple_service, account: account)

    report = Pdf::Report.new(account, service, period: :day)

    assert report.generate
  end

  test 'simple week report' do
    account = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:simple_service, account: account)

    report = Pdf::Report.new(account, service, period: :week)

    assert report.generate
  end

  test 'supports service names with special characters and tags' do
    name_with_special_chars = "Name's with `, & and <b>tag</b>"
    account = FactoryBot.build_stubbed(:simple_provider)
    service = FactoryBot.build_stubbed(:simple_service, account: account, name: name_with_special_chars)

    report = Pdf::Report.new(account, service, period: :day)

    assert report.generate

    text = PDF::Inspector::Text.analyze_file(report.pdf_file_path)
    assert text.strings.any? { |str| str.include? name_with_special_chars }
  end

  test "tags and special characters rendered literally in tables" do
    metric_name = "m<b>&`</b>foo"
    company_name = "c<b>&`</b>foo"
    plan_name = "p<b>&`</b>foo"

    buyer = FactoryBot.create(:buyer_account, org_name: company_name)
    provider = buyer.provider_account
    service = provider.services.first
    plan = FactoryBot.create(:application_plan, issuer: service, name: plan_name, state: 'published')

    cinstance = FactoryBot.create(:cinstance, user_account: buyer, plan: plan)
    custom_metric = FactoryBot.create(:metric, friendly_name: metric_name, owner: service)
    hits_metric = service.metrics.hits!

    today = ActiveSupport::TimeZone.new(buyer.timezone).today

    from = today.prev_day.to_time
    to = today.to_time

    fake_hits(from, to, :clickfest, cinstance, hits_metric)
    fake_hits(from, to, :clickfest, cinstance, custom_metric)

    report = Pdf::Report.new(provider, service, period: :day).generate
    strings = PDF::Inspector::Text.analyze_file(report.pdf_file_path).strings.dup

    assert_operator strings, :delete_at, strings.index(metric_name)
    assert_operator strings, :delete_at, strings.index(plan_name)
    assert_operator strings, :delete_at, strings.index(plan_name)
    assert_operator strings, :delete_at, strings.index(company_name)
    assert_operator strings, :delete_at, strings.index(company_name)
    assert_operator strings, :delete_at, strings.index(buyer.emails.first)
    assert(strings.none? { |str| str.include?("<") || str.include?("&") || str.include?("\\") })
  end
end
