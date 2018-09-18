class BackendRandomDataGeneratorWorker
  include Sidekiq::Worker

  def self.generate(options)
    perform_async(options)
  end

  TIME_KEYS = %i(since until).freeze

  def perform(options)
    options.symbolize_keys!

    TIME_KEYS.each do |key|
      time = options[key] or next
      options[key] = Time.parse(time).utc
    end

    Backend::RandomDataGenerator.generate(options)
  end

end
