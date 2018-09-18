require 'test_helper'

class Csv::MessagesExporterTest < ActiveSupport::TestCase

  def setup
    @provider = Factory.create(:provider_account, org_name: 'Generalitat', domain: 'generalitat.cat')
    create_message_for @provider
    create_message_for @provider, Time.now.utc
  end

  def create_message_for(provider, date = Time.utc(2011,1,1))
    msg = 0
    Timecop.freeze(date) do
      ActionMailer::Base.deliveries = []
      message = Message.create!(:sender => provider, :to => [provider],
                          :subject => 'hello', :body => "what's up?")
      message.deliver!
    end
    msg
  end

  test 'to_csv' do
    Timecop.freeze(Time.utc(2011,1,1)) do
      buyer = Factory.create(:buyer_account,
                             org_name: 'Eater',
                             provider_account: @provider)
      buyer.admins.first.update_attributes(username: 'john_doe', email: 'john@my.company.it')

      plan = @provider.account_plans.default
      plan.update_column(:name, 'Plan of the Escape')
      plan.create_contract_with(buyer)
      exporter = Csv::MessagesExporter.new(@provider, data: "messages")
      lines = exporter.to_csv.lines.to_a

      assert_equal %{Generalitat/generalitat.cat - All Messages / All time (generated 2011-01-01 00:00:00 UTC)\n}, lines[0]
      assert_equal "\n", lines[1]
      assert_equal "Sender,Organization Name,Sent At,Subject,Message\n", lines[2]
      assert_equal @provider.received_messages.count, lines.length - 3
    end
  end

  test 'today' do
    exporter = Csv::MessagesExporter.new(@provider, period: 'today')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'week' do
    exporter = Csv::MessagesExporter.new(@provider, period: 'this_week')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'month' do
    create_message_for(@provider, Time.now.beginning_of_month)
    exporter = Csv::MessagesExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'this year' do
    create_message_for(@provider, Time.now.beginning_of_month)
    exporter = Csv::MessagesExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'last year' do
    create_message_for(@provider, 1.year.ago.utc)
    exporter = Csv::MessagesExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end
end
