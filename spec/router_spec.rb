
RSpec.describe Router do
  subject do
    Router.new do
      get '/index', ->(env) { [200, {}, ['get index']] }
      post '/create', ->(env) { [201, {}, ['post create']] }
      get '/show', ->(env) { [200, {}, ['get show']] }


      get '/create/:name', ->(env) { [200, {}, ['get create with parameter']] }
    end
  end

  context 'request is GET :index' do
    let(:env) { {'REQUEST_PATH' => '/index', 'REQUEST_METHOD' => 'GET'} }

    it 'matches request' do
      expect(subject.call(env)).to eq [200, {}, ['get index']]
    end
  end

  context 'request is POST :create' do
    let(:env) { {'REQUEST_PATH' => '/create', 'REQUEST_METHOD' => 'POST'} }

    it 'matches request' do
      expect(subject.call(env)).to eq [201, {}, ['post create']]
    end
  end

  context 'request is GET :show' do
    let(:env) { {'REQUEST_PATH' => '/show', 'REQUEST_METHOD' => 'GET'} }

    it 'matches request' do
      expect(subject.call(env)).to eq [200, {}, ['get show']]
    end
  end

  context 'request with parameter :create/:name' do
    let(:env) { {'REQUEST_PATH' => '/create/example_name', 'REQUEST_METHOD' => 'GET'} }

    it 'matches request' do
      expect(subject.call(env)).to eq [200, {}, ['get create with parameter']]
    end
  end

  context 'request with wrong path' do
    let(:env) { {'REQUEST_PATH' => '/sdfhsdjf', 'REQUEST_METHOD' => 'GET'} }

    it 'return 404' do
      expect(subject.call(env)).to eq [404, {}, ['Not Found']]
    end
  end
end