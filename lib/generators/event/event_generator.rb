class EventGenerator < Rails::Generators::NamedBase
  argument :attributes, type: :array, default: [], banner: 'parameter parameter'

  source_root File.expand_path('../templates', __FILE__)

  check_class_collision suffix: 'Event'

  def create_event
    template 'event.rb.erb', File.join('app', 'events', class_path, "#{file_name}_event.rb")
  end

  def create_event_test
    template 'event_test.rb.erb', File.join('test', 'events', class_path, "#{file_name}_event_test.rb")
  end
end
