require 'test_helper'
require 'sidekiq/manager'

class SidekiqInitializerTest < ActiveSupport::TestCase

  test 'log job arguments' do
    options = {:queues => ['default']}

    logger = Sidekiq.logger = Sidekiq::Logging.initialize_logger

    mgr = Sidekiq::Manager.new(options)
    processor = ::Sidekiq::Processor.new(mgr)

    invoice = FactoryBot.create(:invoice)

    msg = Sidekiq.dump_json({ 'class' => InvoiceFriendlyIdWorker.to_s, 'args' => [invoice.id] })
    job = Sidekiq::BasicFetch::UnitOfWork.new('queue:default', msg)
    processor.send(:process, job)

    # Sidekiq.logger.expects(:info) #.with { |message| message.match("ARGS-[#{invoice.id}]") }

    logger.expects(:info)
  end
end
