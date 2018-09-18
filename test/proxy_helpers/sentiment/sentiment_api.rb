require 'rubygems'
require 'json'
require 'sinatra'
# require './analyzer.rb'
require File.expand_path(File.dirname(__FILE__) + '/analyzer.rb')
Encoding.default_external = 'UTF-8'

class SentimentApi < Sinatra::Base
  enable :logging
  disable :raise_errors
  disable :show_exceptions

  configure :production do
    disable :dump_errors
  end

  set :server, 'thin'

  helpers do
    def request_headers
      env.inject({}){|acc, (k,v)| acc[$1] = v if k =~ /^http_(.*)/i; acc}
    end
  end

  @@last_authrep_result = {}
  @@last_backend_headers = {}

  @@the_logic = Analyzer.new

  get '/v1/word/:word.json' do
    res = @@the_logic.word(params[:word])
    @@last_backend_headers = request_headers
    content_type 'application/json'
    body res.to_json
    status 200
  end

  # simulating a different service
  get '/v2/word/:word.json' do
    res = @@the_logic.word(params[:word])
    @@last_backend_headers = request_headers
    content_type 'application/json'
    body res.to_json
    status 200
  end


  get '/v1/search.json' do
    res = params[:q]
    @@last_backend_headers = request_headers
    content_type 'application/json'
    body res.to_json
    status 200
  end

  post '/v1/word/:word.json' do
    res = @@the_logic.add_word(params[:word],params[:value])
    @@last_backend_headers = request_headers
    content_type 'application/json'
    body res.to_json
    status 200
  end


  get '/v1/sentence/:sentence.json' do
    res = @@the_logic.sentence(params[:sentence])
    @@last_backend_headers = request_headers
    content_type 'application/json'
    body res.to_json
    status 200
  end

  get '/transactions/authrep.xml' do
    @@last_authrep_result = params.dup
    @@last_authrep_result[:backend_headers] = request_headers
    content_type 'application/xml'
    body ""
    status params[:response_code] || 200
  end

  get '/last_authrep.json' do
    content_type 'application/json'
    res = @@last_authrep_result || {}
    body res.merge(headers: @@last_backend_headers).to_json
    status 200
  end

  get '/transactions/oauth_authorize.xml' do
    code = if (params[:redirect_url] || params[:redirect_uri]) == 'no-match'
      409
           else
      200
           end
    body ""
    status code
  end

  get '/transactions/oauth_authrep.xml' do
    @@last_authrep_result = params.dup
    @@last_authrep_result[:backend_headers] = request_headers
    content_type 'application/xml'
    body ""
    status params[:response_code] || 200
  end

  get '/transactions.xml' do
    status 200
  end

  post("/services/:service_id/oauth_access_tokens.xml") do
    status 200
  end

  get("/read") do
    body "read read"
    status 200
  end

  get("/write") do
    body "write write"
    status 200
  end

  get("/foo") do
    body "foo"
    status 200
  end

  get("/foo/bar") do
    body "foo bar"
    status 200
  end

  get("/foo/:id") do
    body "foo :id"
    status 200
  end

  not_found do
    ""
  end

  error InvalidParameters do
    error_code = 422
    content_type 'application/json'
    error error_code, {:error => {:reason => env['sinatra.error'].to_s, :code => error_code}}.to_json
  end

  error do
    error_code = 500
    content_type 'application/json'
    error error_code, {:error => {:reason => env['sinatra.error'].to_s, :code => error_code}}.to_json
  end

end
