Application = Router.new do
  get '/index', ->(env) { [200, {}, ['get index']] }
  post '/create', ->(env) { [201, {}, ['post create']] }
  get '/show', ->(env) { [200, {}, ['get show']] }

  get '/create/:name', ->(env) { [200, {}, ['get create with parameter']] }
end