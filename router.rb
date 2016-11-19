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
        return route[:app]
      end
    end
    return ->(_env) { [404, {}, ['Not Found']] }
  end

  def match(http_method, path, app)
    # @routes[http_method] ||= {}
    # @routes[http_method][path] = app
    @routes << { pattern: path, app: app, regexp: path_to_regexp(path), mothod: http_method }
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
end