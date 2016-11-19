class Router
  def call(env)
    # @routes[env['REQUEST_METHOD']][env['REQUEST_PATH']].call(env)
    find_route(env).call(env)
  end

  private

  def initialize(&block)
    # @routes = {}
    @routes = []
    instance_exec(&block)
  end

  def find_route(env)
    @routes.each do |route|
      # if env['REQUEST_METHOD'] == route[:method] && env['REQUEST_PATH'] =~ route[:regexp]
      if env['REQUEST_PATH'] =~ route[:regexp]
        env['router.params'] = extract_params(route[:pattern], env['REQUEST_PATH'])
        return route[:app]
      end
    end
    return ->(_env) { [404, {}, ['Not Found']] }
  end

  def match(http_method, path, app)
    # @routes[http_method] ||= {}
    # @routes[http_method][path] = app
    app = get_controller_action(app) if app.is_a? String
    @routes << { pattern: path, app: app, regexp: path_to_regexp(path), mothod: http_method }
  end

  def get_controller_action(string)
    controller_name, action_name = string.split('#') # tests#show=> ['tests', 'show']
    controller_name = to_upper_camel_case(controller_name)
    Kernel.const_get(controller_name).send(:action, action_name)
    # controller_name = public
    # action_name = show
    # PublicTestController.action('show')
  end

  def to_upper_camel_case(string)
    string #public/tests#show  -> Public::TestsController.action(show)  ,   public/tests#show  -> Public::TestsController
      .split('/') #['public', 'test']
      .map { |part| part.split('_').map(&:capitalize).join } # ['Public', 'Test']
      .join('::') + 'Controller'
  end

  def get(path, app)
    match('GET', path, app)
  end

  def post(path, app)
    match('POST', path, app)
  end

  def path_to_regexp(path)
    Regexp.new('\A' + path.gsub(/:[\w-]+/, '[\w-]+') + '\Z')
  end

  def extract_params(pattern, path)
    pattern
      .split('/')                           # ['post', ':name']
      .zip(path.split('/'))                 # [['post','post'][':name','post']]
      .reject { |e| e.first == e.last }     # [[':name','post']]
      .map { |e| [e.first[1..-1], e.last] } # [['a', 'b']].to_h => {"a"=>"b"}    [['name', 'post']]
      .to_h
  end
end