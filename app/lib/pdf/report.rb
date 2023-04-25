# frozen_string_literal: true

require 'SVG/Graph/DataPoint'
require 'SVG/Graph/Line'

# REFACTOR: extract abstract Report class, and DRY functionality with InvoiceReporter
module Pdf
  class Report
    include Printer

    attr_accessor :account, :period, :pdf, :service, :report

    METRIC_HEADINGS_DAY = ["Name", "Today's Total", "% Change"].freeze
    METRIC_HEADINGS_WEEK = ["Name", "Week's Total", "% Change"].freeze
    SIGNUP_HEADINGS = ["Name", "Registered on", "Email", "Plan"].freeze
    TOP_USERS_HEADINGS = %w[Name Hits].freeze
    USERS_HEADINGS = %w[Plan Users].freeze

    def initialize(account, service, options = {})
      @account = account
      @service = service
      @period = options[:period]&.to_sym || :day
      # TODO: accept as parameter
      @style = Pdf::Styles::Colored.new
      @data = Pdf::Data.new(@account, @service, period: @period)

      @pdf = Prawn::Document.new(
        page_size: 'A4',
        page_layout: :portrait,
        compress: true)

      set_default_font
    end

    def generate
      three_scale_logo
      move_down 2

      header

      move_down 3
      traffic_graph
      move_down 3

      traffic_and_users
      move_down 3

      latest_users(10)
      move_down 3

      metrics
      move_down 3

      @pdf.render_file(pdf_file_path)

      self
    end

    def deliver_notification?(user)
      user.notification_preferences.include?(notification_name) && user.admin?
    end

    def send_notification!
      account.admins.map do |admin|
        if deliver_notification?(admin)
          NotificationMailer.public_send(notification_name, self, admin).deliver_now
        else
          Rails.logger.info "[PDF::Report] Skipping delivery of #{period} report to #{admin}"
        end
      end
    end

    def notification_name
      case period
      when :day then :daily_report
      when :week then :weekly_report
      else raise "unknown notification for period #{period}"
      end
    end

    # REFACTOR: this class should not be responsible for mailing
    def mail_report
      PostOffice.report(self, print_period).deliver_now
    end

    def pdf_file_name
      ['report', @account.internal_domain, @service.id].join('-') + '.pdf'
    end

    def pdf_file_path
      Rails.root.join('tmp', pdf_file_name)
    end

    def print_period
      notification_name.to_s.split("_").map(&:capitalize).join(" ")
    end

    def header
      @pdf.formatted_text([
                            { text: print_period.to_s, **@style[:period] },
                            { text: " (", size: @style[:period][:size] },
                            { text: "#{account.external_domain} - #{@service.name}", **@style[:domain] },
                            { text: ")", size: @style[:period][:size] },
                          ])
      header_height = @style[:date][:size] + 2.mm
      @pdf.repeat :all do
        pdf.formatted_text_box header_text,
                               at: [@pdf.margin_box.left, @pdf.margin_box.top + header_height],
                               width: @pdf.bounds.width,
                               height: header_height,
                               align: :right
      end
    end

    def latest_users(count)
      subtitle "Latest Signups"
      table_if_data(@data.latest_users(count), SIGNUP_HEADINGS)
    end

    def traffic_and_users
      two_columns do |column|
        case column
        when :left
          if (users = @data.top_users)
            subtitle 'Top Users'
            table_if_data(users, TOP_USERS_HEADINGS, TABLE_HALF_WIDTH)
          end
        when :right
          subtitle "Users"
          table_if_data(@data.users, USERS_HEADINGS, TABLE_HALF_WIDTH)
        end
      end
    end

    def graph_key_formatter(usage)
      if @period == :day
        ->(point) { (point % 4).zero? ? sprintf("%02d:00", point) : "" }
      else
        since = usage.dig(:period, :since)
        granularity = usage.dig(:period, :granularity)
        ->(point) { (point % 4).zero? ? (since + point * granularity).strftime("%d %b") : "" }
      end
    end

    def traffic_graph
      usage = @data.usage

      return unless usage

      options = {
        graph_title: "Traffic - #{usage.dig(:metric, :name)}",
        show_graph_title: true,
        key: false,
        area_fill: false,
        show_data_values: false,
        add_popups: false,
        width: TABLE_FULL_WIDTH,
        height: TABLE_FULL_WIDTH / 4,
        step_x_labels: 4,
        step_include_first_x_label: true,
        fields: usage[:values].each_index.map(&graph_key_formatter(usage)),
        show_x_title: false,
        x_title: @period == :day ? "Hour" : "Week Days",
        show_y_guidelines: true,
        scale_integers: true,
        scale_divisions: [2, (usage[:values].max - usage[:values].min) / 5].max,
        number_format: IntegerWithDelimiterFormatter.new,
        show_y_title: false,
        y_title: usage.dig(:metric, :name),
        y_title_location: :middle,
        no_css: false,
      }

      graph = SVG::Graph::Line.new(options)

      graph.add_data(data: usage[:values], title: options[:y_title])

      @pdf.svg traffic_graph_style(graph.burn_svg_only)
    end

    def traffic_graph_style(svg)
      xml = Nokogiri::XML(svg)
      style = xml.at_css("style")
      css = CssParser::Parser.new
      css.load_string!(style.text.gsub(/ff0000/i, "9273ED"))
      traffic_graph_first_data_point(xml)
      traffic_graph_y_align(xml)
      traffic_graph_style_clean_up(css)
      traffic_graph_style_guide_lines(css)
      traffic_graph_style_axes(css)
      traffic_graph_style_line_width(css)
      traffic_graph_style_background(css)
      traffic_graph_style_text(css)

      style.content = css.to_s
      xml.to_s
    end

    # TODO: remove this hack ofter fix is acepted upstream
    #       https://github.com/lumean/svg-graph2/pull/43
    def traffic_graph_first_data_point(xml)
      line = xml.at_css(".line1")
      line[:d] = line[:d].sub(/^M.+L\s*(\S+\s+\S+)(.*)$/, 'M\1 L\2')
    end

    # TODO: remove this hack after fix is accepted upstream
    #       https://github.com/lumean/svg-graph2/pull/44
    def traffic_graph_y_align(xml)
      xml.css(".yAxisLabels").each do |label|
        label[:x] = "-8"
        label.delete("style")
        label.delete("transform")
      end
    end

    def traffic_graph_style_background(css)
      desired = <<-EOT
      .graphBackground { 
        fill:#ffffff;
      }
      EOT

      css.remove_rule_set!(css.find_rule_sets([".graphBackground"]).first)
      css.add_block!(desired)
    end

    def traffic_graph_style_text(css)
      desired = <<-EOT
        .xAxisLabels,.yAxisLabels {
          fill:#909090;
          font-size: 10px;
          font-family: "#{@style[:font]}", sans-serif; font-weight: normal;
        }
        .mainTitle {
          fill:#505050;
          font-family: "#{@style[:font]}", sans-serif; font-weight: normal;
        }
      EOT

      css.add_block!(desired)
    end

    def traffic_graph_style_axes(css)
      desired = <<-EOT
      .axis{
        stroke: #ffffff;
        stroke-width: 0px;
      }
      EOT

      css.remove_rule_set!(css.find_rule_sets([".axis"]).first)
      css.add_block!(desired)
    end

    def traffic_graph_style_line_width(css)
      desired = <<-EOT
      .line1 {
        stroke-width: 2px;
      }
      EOT

      css.add_block!(desired)
    end

    def traffic_graph_style_guide_lines(css)
      desired = <<-EOT
      .guideLines,#yAxis {
        stroke: #eeeeee;
        stroke-width: 0.3px;
        stroke-dasharray: 0.01 1;
        stroke-linejoin: round;
        stroke-linecap: round;
      }
      EOT

      css.remove_rule_set!(css.find_rule_sets([".guideLines"]).first)
      css.add_block!(desired)
    end

    def traffic_graph_style_clean_up(css)
      (2..12).each do |num|
        %w[line fill key dataPoint].each do |type|
          rule = css.find_rule_sets([".#{type}#{num}"]).first
          css.remove_rule_set!(rule) if rule.present?
        end
      end
    end

    def metrics
      subtitle "Metrics"
      return unless %i[day week].include? @period

      header = self.class.const_get("METRIC_HEADINGS_#{@period}".upcase)
      lines = @data.metrics.map { |name, total, percent| [name, total, colorize_num(percent)] }
      table_with_header([header, *lines])
    end

    private

    def header_text
      format = @style[:date]
      if @period == :day
        [{ text: 1.day.ago.to_date.to_s }.merge!(format)]
      else
        [
          { text: 1.week.ago.to_date.to_s }.merge!(format),
          { text: " - " },
          { text: 1.day.ago.to_date.to_s }.merge!(format),
        ]
      end
    end

    def three_scale_logo
      logo = File.dirname(__FILE__) + "/images/logo.png"
      image = @pdf.image logo, width: 100
      dimensions = [
        @pdf.bounds.absolute_left,
        @pdf.bounds.absolute_top - image.scaled_height,
        @pdf.bounds.absolute_left + image.scaled_width,
        @pdf.bounds.absolute_top
      ]
      url = PDF::Core::LiteralString.new("https://3scale.net")
      @pdf.link_annotation(dimensions, Border: [0,0,0], A: { Type: :Action, S: :URI, URI: url})
    end

    def table_if_data(data, header, width = TABLE_FULL_WIDTH)
      return @pdf.text("No current data", **@style[:small]) if data.blank?

      table_with_header([header] + data, width: width)
    end

    # @param numstr [String] string representing a number
    def colorize_num(numstr)
      case numstr.to_f
      when 0.0
        numstr
      when -Float::INFINITY...0
        { content: numstr, **@style[:red] }
      else
        { content: numstr, **@style[:green] }
      end
    end

    class IntegerWithDelimiterFormatter
      include ActionView::Helpers::NumberHelper

      def %(num)
        number_with_delimiter(num.to_i)
      end
    end
  end
end
