require 'prawn/core'
require 'prawn/format'
require 'prawn/measurement_extensions'
require 'gruff'

# REFACTOR: extract abstract Report class, and DRY functionality with InvoiceReporter
module Pdf
  class Report
    include Printer

    attr_accessor :account, :period, :pdf, :service, :report

    METRIC_HEADINGS_DAY   = Format.prep_th ["Name", "Today's Total", "% Change"]
    METRIC_HEADINGS_WEEK  = Format.prep_th ["Name", "Week's Total",  "% Change"]
    SIGNUP_HEADINGS       = Format.prep_th ["Name", "Registered on", "Email", "Plan"]
    TOP_USERS_HEADINGS    = Format.prep_th ["Name", "Hits"]
    USERS_HEADINGS        = Format.prep_th ['Plan', "Users"]

    def initialize(account, service, options = {})
      @account = account
      @service = service
      @period = options[:period] || :day
      # TODO: accept as parameter
      @style = Pdf::Styles::Colored.new
      @data = Pdf::Data.new(@account, @service, :period => @period)

      @pdf = Prawn::Document.new(
                                 :page_size => 'A4',
                                 :page_layout => :portrait)

      @pdf.tags(@style.tags)
      @pdf.font(@style.font)
    end

    def generate
      three_scale_logo
      move_down 2

      header

      traffic_graph
      traffic_and_users
      move_down 3

      latest_users(10)
      move_down 3

      metrics
      move_down 3

      @report = @pdf.render_file(Rails.root.join 'tmp', "#{@account.domain} #{@service.name}.pdf")

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
      [@account.id, @service.id, 'report.pdf'].join '_'
    end

    def print_period
      return "Daily Report" if @period == :day
      return "Weekly Report" if @period == :week
    end

    def header
      @pdf.text "<period>#{print_period}</period> (<domain>#{account.domain} - #{EscapeUtils.escape_html(@service.name)}</domain>)"
      @pdf.header @pdf.margin_box.top_left do
        if @period == :day
          @pdf.text "<date>#{1.day.ago.to_date}</date>", :align => :right
        else
          @pdf.text "<date>#{1.day.ago.to_date}</date> - <date>#{1.week.ago.to_date}</date>", :align => :right
        end
      end
    end

    def latest_users(count)
      subtitle "Latest Signups"
      print_table(@data.latest_users(count), TABLE_FULL_WIDTH, SIGNUP_HEADINGS)
    end

    def traffic_and_users
      two_columns([0.mm, 194.mm], :height => 40.mm) do |column|
        case column
        when :left
          if (users = @data.top_users)
            subtitle 'Top Users'
            print_table(users, TABLE_HALF_WIDTH, TOP_USERS_HEADINGS)
          end
        when :right
          subtitle "Users"
          print_table(@data.users, TABLE_HALF_WIDTH, USERS_HEADINGS)
        end
      end
    end

    def traffic_graph
      if (graph = @data.traffic_graph)
        subtitle "Traffic"
        @pdf.image graph, :position => :left, :width => 520
      end
    end

    def metrics
      subtitle "Metrics"
      if @period == :day
        print_table(@data.metrics, TABLE_FULL_WIDTH, METRIC_HEADINGS_DAY)
      elsif @period == :week
        print_table(@data.metrics, TABLE_FULL_WIDTH, METRIC_HEADINGS_WEEK)
      end
    end

    private

    def three_scale_logo
      logo = File.dirname(__FILE__) + "/images/logo.png"
      @pdf.image logo, :width => 100
    end

    def print_table(data, width, headings)
      unless data.blank?
        options = { :headers => headings, :width => width }
        @pdf.table data, @style.table_style.merge(options)
      else
        @pdf.text "<small>No current data</small>"
      end
    end
  end
end
