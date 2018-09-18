class SubscriberGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  check_class_collision suffix: 'Subscriber'

  def create_subscriber
    template 'subscriber.rb.erb', "app/subscribers/#{file_name}_subscriber.rb"
  end

  def create_subscriber_test
    template 'subscriber_test.rb.erb', "test/subscribers/#{file_name}_subscriber_test.rb"
  end

  def enable_subscribe
    insert_into_file 'lib/event_store/repository.rb',
                     "  @client.subscribe(#{class_name}Subscriber.new, [#{class_name}Event])\n  ",
                     after: /@client.subscribe.+\n\s+(?=end)/
  end
end
