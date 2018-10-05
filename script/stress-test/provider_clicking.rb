require 'pry' rescue nil
require 'openssl'
require 'active_support/core_ext'
require 'mechanize'
require 'securerandom'


class ProviderClicking
  class LoginError < StandardError
    def initialize(username, password)
      super "couldn't login with #{username} and #{password}"
    end
  end

  def initialize(url, username, password, access_code)
    @url = url
    @agent = Mechanize.new
    @username = username
    @password = password
    @access_code = access_code
  end

  def perform!
    log_in! unless logged_in?
    raise LoginError.new(@username, @password) unless logged_in?

    action = available_actions.sample
    send(action)
    "#{self.class}: #{action}"
  end

  def available_actions
    [:list_accounts, :create_account, :list_apps, :create_app]
  end

  def list_apps
    root.link_with(text: 'Applications').click
  end

  def create_app
    form = new_application.form_with(:method => 'POST')
    form['cinstance[name]'] = generate
    form.field_with(id: 'cinstance_plan_id').options.sample.click
    form.submit
  end

  def list_accounts
    root.link_with(:text => 'Accounts').click
  end

  def create_account
    form = new_account.form_with(method: 'POST')
    name = generate

    form['account[org_name]'] = name

    form['account[user][email]'] = "#{name}@mailinator.com"
    form['account[user][username]'] = name
    form['account[user][password]'] = name
    form['account[user][password_confirmation]'] = name

    form.submit
  end

  private

  def new_application(account = show_account)
    account.link_with(text: 'Create Application').click
  end

  def generate
    SecureRandom.uuid
  end

  def show_account(account = accounts.sample)
    account.click
  end

  def new_account
    @new_account ||= list_accounts.link_with(text: 'Create').click
  end

  def applications
    get_ids list_apps.links_with(href: %r{^/admin/services/\d+/applications/\d+$})
  end

  def accounts
    list_accounts.links_with(href: %r|^/admin/buyers/accounts/\d+$|, text: %r|^(?!Delete)|)
  end

  def get_ids(links)
    links.map{|link| link.href.scan(%r|/(\d+)/?|).join.to_i }
  end

  def logged_in?
    @dashboard and @dashboard.search('#user_widget').present?
  end

  def log_in!
    page = @agent.get(@url)

    if form = page.form_with(:action => '/access_code')
      form.access_code = @access_code
      page = @agent.submit(form)
    end

    form = page.form_with(:action => '/p/sessions')
    form.username = @username
    form.password = @password
    @dashboard = @agent.submit(form)
  end

  def root
    @dashboard
  end
end
