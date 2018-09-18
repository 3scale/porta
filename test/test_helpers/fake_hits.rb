module TestHelpers
  module FakeHits
    # Value is either number of hits or one of
    #
    # :clickfest - all the hours, every day, get as many hits as is the current date (1..31)
    # Hash - every key is hour, its value is number of hits
    # Array - like clickfest, but hits only selected hours
    # Integer - fills the whole range with this value of hits
    #
    # Note: assumes @cinstance and @metric are set
    #
    def fake_hits(from, to, value, cinstance = @cinstance, metric = @metric)
      zone = ActiveSupport::TimeZone.new('UTC')
      now = zone.local(*from)

      while now <= zone.local(*to)
        case value
        when Hash then fake_selected_hours(now, value, cinstance, metric)
        when Array, Range then fake_hours_in_range(now, :clickfest, value, cinstance, metric)
        when :clickfest then fake_hours_in_range(now, :clickfest, 0..23, cinstance, metric)
        else fake_hours_in_range(now, value, 0..23, cinstance, metric)
        end

        now = now + 1.day
      end
    end

    def fake_hit(time, value, cinstance = @cinstance, metric = @metric)
      ::Backend::Transaction.report!(:cinstance  => cinstance,
                                     :service_id => cinstance.service.id,
                                     :usage      => { metric.name => value},
                                     :created_at => time,
                                     :confirmed  => true)
    end

    private

    def fake_selected_hours(date, values, cinstance, metric)
      values.each do |h,v|
        fake_hit(date + h.to_i.hours, v, cinstance, metric)
      end
    end

    def fake_hours_in_range(date, value, range, cinstance, metric)
      range.each do |h|
        v = (value == :clickfest) ? date.day : value
        fake_hit(date + h.hours, v, cinstance, metric)
      end
    end

  end
end
