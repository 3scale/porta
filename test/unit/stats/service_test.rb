require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::ServiceTest < ActiveSupport::TestCase
  def setup
    Timecop.return
    # TestHelpers::Time::set_format("%a, %e %B %Y %k:%M")
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.first_service!
    @metric = @service.metrics.hits!

    @storage = Stats::Base.storage
    @storage.flushdb

    @zone = ActiveSupport::TimeZone['UTC']

    # it fails with pacific time
    # @zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
    # @zone = ActiveSupport::TimeZone['Samoa'] + 14h
    # @zone = ActiveSupport::TimeZone['International Date Line West'] - 12h
  end

  test 'Service#usage includes timezone in its response' do
    data = Stats::Service.new(@service).usage(:metric => @metric,
                                              :since  => @zone.local(2009, 12, 4).to_s,
                                              :until => @zone.local(2009, 12, 5).to_s,
                                              :timezone => @zone.name,
                                              :granularity => 'hour')

    assert_equal 'Etc/UTC', data[:period][:timezone]
  end

  test 'Service#usage accepts time range as :period and :since' do
    data = Stats::Service.new(@service).usage(:metric => @metric,
                                              :period => :month,
                                              :timezone => @zone.name,
                                              :since  => @zone.local(2009, 12, 4).to_s)

    assert_equal @zone.local(2009, 12, 4), data[:period][:since]
    assert_equal @zone.local(2010,  1, 3).end_of_day, data[:period][:until]
  end

  test 'Service#usage accepts time range as :period only' do
    Timecop.freeze(@zone.local(2009, 12, 4, 17, 25)) do
      data = Stats::Service.new(@service).usage(:metric => @metric,
                                                :period => :month,
                                                :timezone => @zone.name)

      assert_equal @zone.local(2009, 11, 4),            data[:period][:since]
      assert_equal @zone.local(2009, 12, 4).end_of_day, data[:period][:until]
    end
  end

  test 'Service#usage accepts time range as :since, :until and :granularity' do
    data = Stats::Service.new(@service).usage(:metric => @metric,
                                              :since => @zone.local(2009, 12, 4, 22, 14).to_s,
                                              :until => @zone.local(2009, 12, 8, 18, 10).to_s,
                                              :granularity => :hour,
                                              :timezone => @zone.name)


    Time.freeze do
      assert_equal @zone.local(2009, 12, 4, 22),             data[:period][:since]
      assert_equal @zone.local(2009, 12, 8, 18).end_of_hour, data[:period][:until]
    end
  end

  test 'Service#usage accepts time range as :range and :granularity' do
    data = Stats::Service.new(@service).usage(
      :metric => @metric,
      :range => @zone.local(2009, 12, 4, 22, 14)..@zone.local(2009, 12, 8, 18, 10),
      :granularity => :hour,
      :timezone => @zone.name)

    Time.freeze do
      assert_equal @zone.local(2009, 12, 4, 22),             data[:period][:since]
      assert_equal @zone.local(2009, 12, 8, 18).end_of_hour, data[:period][:until]
    end
  end

  test 'Service#usage accepts duration as :granularity' do
    data = Stats::Service.new(@service).usage(
      :metric => @metric,
      :range => @zone.local(2009, 12, 4, 21, 14)..@zone.local(2009, 12, 8, 18, 10),
      :granularity => 6.hours,
      :timezone => @zone.name)

    Time.freeze do
      assert_equal @zone.local(2009, 12, 4, 18),             data[:period][:since]
      assert_equal @zone.local(2009, 12, 8, 23).end_of_hour, data[:period][:until]
    end
  end

  test 'Service#usage accepts metric as :metric' do
    data = Stats::Service.new(@service).usage(:metric => @metric, :period => :month, :timezone => @zone.name)

    assert_equal @metric.to_param.to_i, data[:metric][:id]
    assert_equal @metric.friendly_name, data[:metric][:name]
  end

  test 'Service#usage accepts metric as :metric_name' do
    data = Stats::Service.new(@service).usage(:metric_name => @metric.name, :period => :month, :timezone => @zone.name)

    assert_equal @metric.to_param.to_i, data[:metric][:id]
    assert_equal @metric.friendly_name, data[:metric][:name]
  end

  test 'Service#usage returns hash with usage data' do
    # some fake data
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091204", 123)
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091205", 822)
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091208", 910)

    data = Stats::Service.new(@service).usage(:metric => @metric,
                                              :granularity => :day,
                                              :since => @zone.local(2009, 12, 1).to_s,
                                              :until => @zone.local(2009, 12, 31).to_s,
                                              :timezone => @zone.name)

    assert_equal [0, 0, 0, 123, 822, 0, 0, 910] + [0] * 23, data[:values]
  end

  test 'Service#top_clients returns array of entries for the most active clients' do
    plan = FactoryBot.create( :application_plan, :issuer => @service)

    cinstance1 = FactoryBot.create(:cinstance, :plan => plan, :name => 'cinstance1')
    cinstance2 = FactoryBot.create(:cinstance, :plan => plan, :name => 'cinstance2')
    cinstance3 = FactoryBot.create(:cinstance, :plan => plan)

    key = lambda do |cinstance|
      "stats/{service:#{@service.backend_id}}/cinstance:#{cinstance.application_id}/metric:#{@metric.id}/month:20091201"
    end

    # fake data
    @storage.set(key.call(cinstance1), 25)
    @storage.set(key.call(cinstance2), 67)
    @storage.set(key.call(cinstance3), 13)

    @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance1.application_id)
    @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance2.application_id)
    @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance3.application_id)

    @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance1.application_id}/metric:#{@metric.id}/day:20091204", 123)
    @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance2.application_id}/metric:#{@metric.id}/day:20091205", 822)
    @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance3.application_id}/metric:#{@metric.id}/day:20091208", 910)

    data = Stats::Service.new(@service).top_clients(:metric => @metric,
                                                    :period => :month,
                                                    :timezone => @zone.name,
                                                    :since => @zone.local(2009, 12, 1).to_s)
    # contains :applications, :metric, :period
    assert_equal 3, data.size

    assert_equal 3, data[:applications].size
    app_a = data[:applications][0]
    app_b = data[:applications][1]
    app_c = data[:applications][2]

    assert_equal app_a[:account][:name], cinstance2.user_account.org_name
    assert_equal app_b[:account][:name], cinstance1.user_account.org_name
    assert_equal app_c[:account][:name], cinstance3.user_account.org_name

    assert_equal app_a[:value], "67"
    assert_equal app_b[:value], "25"
    assert_equal app_c[:value], "13"

    # No longer returning usage data
    # assert_equal client_a[:usage][:total].to_s, "822"
    # assert_equal client_b[:usage][:total].to_s, "123"
    # assert_equal client_c[:usage][:total].to_s, "910"

  end

  test 'Service#top_clients returns a normalized period' do
    data = Stats::Service.new(@service).top_clients(:metric => @metric,
                                                    :period => :week,
                                                    :timezone => @zone.name,
                                                    :since => @zone.local(2016, 11, 25).to_s)

    assert_equal @zone.local(2016, 11, 21, 00),             data[:period][:since]
    assert_equal @zone.local(2016, 11, 27, 23).end_of_hour, data[:period][:until]
  end

  # test 'Service#top_clients returns array of entries for the most active clients timezoned' do
  #   Time.zone = 'Hawaii'
  #   @zone = Time.zone

  #   plan = FactoryBot.create( :application_plan, :issuer => @service)

  #   cinstance1 = FactoryBot.create(:cinstance, :plan => plan, :name => 'cinstance1')
  #   cinstance2 = FactoryBot.create(:cinstance, :plan => plan, :name => 'cinstance2')
  #   cinstance3 = FactoryBot.create(:cinstance, :plan => plan)

  #   key = lambda do |cinstance|
  #     "stats/{service:#{@service.backend_id}}/cinstance:#{cinstance.application_id}/metric:#{@metric.id}/month:20091201"
  #   end

  #   # fake data
  #   @storage.set(key.call(cinstance1), 25)
  #   @storage.set(key.call(cinstance2), 67)
  #   @storage.set(key.call(cinstance3), 13)

  #   @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance1.application_id)
  #   @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance2.application_id)
  #   @storage.sadd("stats/{service:#{@service.backend_id}}/cinstances", cinstance3.application_id)

  #   @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance1.application_id}/metric:#{@metric.id}/day:20091204", 123)
  #   @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance2.application_id}/metric:#{@metric.id}/day:20091205", 822)
  #   @storage.set("stats/{service:#{@service.backend_id}}/cinstance:#{cinstance3.application_id}/metric:#{@metric.id}/day:20091208", 910)

  #   data = Stats::Service.new(@service).top_clients(:metric => @metric,
  #                                                   :period => :month,
  #                                                   :timezone => @zone.name,
  #                                                   :since => @zone.local(2009, 12, 1).to_s)
  #   # contains :applications, :metric, :period
  #   assert_equal 3, data.size

  #   assert_equal 3, data[:applications].size
  #   app_a = data[:applications][0]
  #   app_b = data[:applications][1]
  #   app_c = data[:applications][2]

  #   assert_equal app_a[:account][:name], cinstance2.user_account.org_name
  #   assert_equal app_b[:account][:name], cinstance1.user_account.org_name
  #   assert_equal app_c[:account][:name], cinstance3.user_account.org_name

  #   assert_equal app_a[:value], "67"
  #   assert_equal app_b[:value], "25"
  #   assert_equal app_c[:value], "13"
  # end

  test 'Service#top_countries returns array of entries for the countries with the greatest activity' do
    Country.delete_all
    us = Country.find_or_create_by!(:code => 'US', :name => 'United States')
    gb = Country.find_or_create_by!(:code => 'GB', :name => 'United Kingdom')
    es = Country.find_or_create_by!(:code => 'ES', :name => 'Spain')

    key = lambda do |code|
      "stats/{service:#{@service.backend_id}}/country:#{code}/metric:#{@metric.id}/month:20091201"
    end

    # fake data
    @storage.set(key.call('GB'), 321)
    @storage.set(key.call('US'), 240)
    @storage.set(key.call('ES'), 188)

    @storage.sadd("stats/{service:#{@service.backend_id}}/countries", 'US')
    @storage.sadd("stats/{service:#{@service.backend_id}}/countries", 'ES')
    @storage.sadd("stats/{service:#{@service.backend_id}}/countries", 'GB')

    data = Stats::Service.new(@service).top_countries(:metric => @metric,
                                                      :period => :month,
                                                      :since => @zone.local(2009, 12, 1).to_s,
                                                      :timezone => @zone.name)

    assert_equal 3, data.size

    assert_equal({:country_name => gb.name,
                  :country_code => gb.code,
                  :value        => "321"}, data[0])

    assert_equal({:country_name => us.name,
                  :country_code => us.code,
                  :value        => "240"}, data[1])

    assert_equal({:country_name => es.name,
                  :country_code => es.code,
                  :value        => "188"}, data[2])
  end

  test 'Service#total returns single summed value' do
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/month:20091201", 1024)
    data = Stats::Service.new(@service).total(:metric => @metric,
                                              :period => :month,
                                              :timezone => @zone,
                                              :since => @zone.local(2009, 12, 1).to_s)

    assert_equal(1024, data)
  end

  test 'Service#active_clients_progress returns hash with progress, total and change' do
    plan = FactoryBot.create( :application_plan, :issuer => @service)

    # fake data
    Timecop.freeze(@zone.local(2009, 11, 19)) { FactoryBot.create(:cinstance, :plan => plan) }
    Timecop.freeze(@zone.local(2009, 12,  4)) { FactoryBot.create(:cinstance, :plan => plan) }
    Timecop.freeze(@zone.local(2009, 12, 22)) { FactoryBot.create(:cinstance, :plan => plan) }
    Timecop.freeze(@zone.local(2010,  1,  3)) { FactoryBot.create(:cinstance, :plan => plan) }

    source = Stats::Service.new(@service)

    data = source.active_clients_progress(:since => @zone.local(2009, 12, 1),
                                          :until => @zone.local(2009, 12, 31),
                                          :timezone => @zone)

    assert_equal 3, data[:total]
    assert_equal 200.0, data[:change]
    assert_equal [1, 1, 1] + [2] * 18 + [3] * 10, data[:progress]
  end

  test 'Service#usage_progress returns hash with progress and total' do
    # some fake data
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091120", 40)
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091204", 50)
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091205", 70)
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091208", 60)

    source = Stats::Service.new(@service)

    data = source.usage_progress(:metric => @metric,
                                 :since => @zone.local(2009, 12, 1),
                                 :until => @zone.local(2009, 12, 31),
                                 :timezone => @zone.name,
                                 :granularity => :day)

    assert_equal 180, data[:data][:total]
  end

  test 'Service#total_hits over eternity' do
    @storage.set("stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/eternity", 123)
    source = Stats::Service.new(@service)

    assert_equal 123, source.total_hits(:period => :eternity)
  end
end
