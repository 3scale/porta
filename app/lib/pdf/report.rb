# frozen_string_literal: true

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

    def traffic_graph
      graph = @data.traffic_graph
      return unless graph
      subtitle "Traffic"
      @pdf.image graph, position: :left, width: 520
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
          { text: 1.day.ago.to_date.to_s }.merge!(format),
          { text: " - " },
          { text: 1.week.ago.to_date.to_s }.merge!(format),
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
  end
end
