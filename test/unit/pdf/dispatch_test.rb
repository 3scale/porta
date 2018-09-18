require 'test_helper'

class Pdf::DispatchTest < ActiveSupport::TestCase
  test 'enqueues report worker' do
    account = FactoryGirl.create(:simple_provider, state: 'approved')
    service = FactoryGirl.create(:simple_service, account: account)

    assert_difference PdfReportWorker.jobs.method(:count), 2 do
      Pdf::Dispatch.daily
    end
    first, second = PdfReportWorker.jobs.map { |job| job.fetch('args') }

    assert_equal [master_account.first_service!.id, Account.master.id, 'day', 'daily_reports'], first
    assert_equal [service.id, account.id, 'day', 'daily_reports'], second
  end

  test 'not enqueue report for deleted services' do
    account = FactoryGirl.create(:simple_provider, state: 'approved')
    FactoryGirl.create(:simple_service, account: account, state: 'deleted')

    # Only master is reported
    assert_difference PdfReportWorker.jobs.method(:count), 1 do
      Pdf::Dispatch.daily
    end

    job = PdfReportWorker.jobs.first.fetch('args')
    assert_equal [master_account.first_service!.id, Account.master.id, 'day', 'daily_reports'], job
  end

  test 'not enqueue report for non approved accounts' do
    account = FactoryGirl.create(:simple_provider, state: 'suspended')
    FactoryGirl.create(:simple_service, account: account)

    # Only master is reported
    assert_difference PdfReportWorker.jobs.method(:count), 1 do
      Pdf::Dispatch.daily
    end

    job = PdfReportWorker.jobs.first.fetch('args')
    assert_equal [master_account.first_service!.id, Account.master.id, 'day', 'daily_reports'], job
  end
end
