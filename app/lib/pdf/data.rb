# frozen_string_literal: true
require 'gruff'

module Pdf
  class Data

    include ERB::Util

    def initialize(account, service, options)
      raise ArgumentError,'No period supplied' unless options[:period]

      @account = account
      @service = service
      @period = options[:period]
      @hit_metric = @service.metrics.hits
      @source = Stats::Service.new(@service)

      @options = {
        :period => @period,
        :metric_name => @hit_metric.try!(:name),
        :since => 1.send(@period).ago.strftime("%Y-%m-%d"),
        :timezone => @account.timezone
      }
    end


    def latest_users(count)
      latest_cinstances = Cinstance.select(:user_account_id).distinct
        .from(@service.cinstances.latest(count), Cinstance.table_name)

      # we want only distinct accounts with cinstance from this service, so fetch them
      buyers = @account.buyer_accounts
                 .where(id: latest_cinstances)
                 .reorder(created_at: :desc)
      buyers.map do |account|
        # because account can have multiple cinstances from multiple services, scope them by service and find last one
        cinstance = account.bought_cinstances.by_service(@service).latest.first or next
        [
          sanitize_text(account.org_name),
          account.created_at,
          account.users.first.try!(:email),
          cinstance.plan.name
        ].map{|v| "<td>#{h v}</td>"}
      end.compact
    end

    def cinstances_change
       @service.cinstances.where('`cinstances`.created_at > ?',1.send(@period).ago.beginning_of_day).count
    end

    def top_users
      return unless @hit_metric

      data_source = Stats::Service.new(@service)
      options = {:metric => @hit_metric, :period => @period, :timezone => @account.timezone,
                 :since => 1.send(@period).ago, :limit => 5}
      apps = data_source.top_clients(options)[:applications] || []
      apps.inject([]) do |memo, entry|
        next if entry[:id].nil? # there are some data inconsistencies in our dbs
        cinstance = @service.cinstances.find(entry[:id])

        memo << Format.prep_td([cinstance.user_account.org_name, entry[:value]])
        memo
      end
    end


    def users
      @service.published_plans.map{|p| Format.prep_td([p.name, p.cinstances.count])}
    end

    def metrics
      data_source = Stats::Service.new(@service)

      data = @source.usage_progress_for_all_metrics(@options)[:metrics]
      data.inject([]) do |row, (metric, stats)|
        row << Format.prep_td_with_negation([metric[:name], metric[:data][:total], "#{"%0.2f" % metric[:data][:change]} %"])
      end
    end


    def traffic_graph
      return if @hit_metric.nil?

      data = @source.usage(@options)

      g = Gruff::Line.new('1200x300')

      g.theme = {
        :colors => ['#9172EC', '#306EFF', '#000066', '#B4B4B4'],
        :font_color => '#555',
        :marker_color => '#eeeeee',
        :background_colors => ['#ffffff', '#ffffff'],
      }

      g.legend_box_size = 10
      g.hide_title = true
      g.legend_font_size = 13
      g.hide_line_markers = false
      g.marker_font_size = 13
      g.hide_dots = false
      g.dot_radius = 3
      g.line_width = 2
      g.marker_count = 5
      g.margins = 2

      g.sort = false
      g.x_axis_label = @period == :day ? "Hour" : "Week Days"
      g.y_axis_label = @hit_metric.friendly_name

      data = data[:values]
      g.data(@hit_metric.friendly_name, data)

      max = data.max
      g.maximum_value = max + (max / 5)

      g.labels = send("#{@period}_labels")
      graph_image = StringIO.new(g.to_blob("JPG"))
    end

    def week_labels
      # Week report, there are 28 data points, at 6 hour intervals
      # What was the date 1 week ago
      date = 1.week.ago.beginning_of_day

      #Gruff expects labels to be presented as a hash
      labels= {}
      (0..27).each do |point|
        # Insert blanks except for every 4th data point (covering a 24hr period)
        if point % 4 == 0
          labels[point] = date.strftime("%d %b")
          date = date + 1.day
        end
      end

      labels
    end


    def day_labels
      # See week_labels
      date = 1.day.ago.beginning_of_day

      labels = {}
      (0..23).each do |point|
        if point % 4 == 0
          labels[point] = date.strftime("%k:00")
        end
        date = date + 1.hour
      end
      labels
    end

    def sanitize_text(text)
      EscapeUtils.escape_javascript(text.to_s)
    end
  end
end
