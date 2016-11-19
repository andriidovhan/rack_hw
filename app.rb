class TestsController
  RESPONSE_TYPES = {
      text: ['text/plain', ->(c) { c.to_s }],
      json: ['Applications/json', ->(c) { Oj.dump(c) }]
  }.freeze

  def call(env)
    @env = env
    @request = Rack::Request.new(env)
    @request.params.merge!(env['router.params'] || {})
    send(@action_name)
    [200, @response_headers, [@response_body]]
  end

  def show
    response(:text, params)
  end

  def show_http_meth
    response(:text, "Request methos is #{request.request_method}")
  end

  def self.action(action_name)
    proc { |env| new(action_name).call(env)}
    # new(action_name)
  end

  private
    attr_reader :request

    def initialize(action_name)
      @action_name = action_name
    end

    def params
      request.params
    end

    def response(type, content)
      @response_headers ||= {}
      @response_headers.merge!('Content-Type' => RESPONSE_TYPES[type][0])
      @response_body = RESPONSE_TYPES[type][1].call(content)
    end
end

Application = Router.new do
  get '/index', ->(env) { [200, {}, ['get index']] }
  # post '/create', ->(env) { [201, {}, ['post create']] }
  get '/show', ->(env) { [200, {}, ['get show']] }

  # get '/create/:name', ->(env) { [200, {}, ['get create with parameter']] }
  get '/create/:your_parameter', 'tests#show'
  get '/show_http_method', 'tests#show_http_meth'
end