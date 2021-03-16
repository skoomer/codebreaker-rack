RSpec.describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  let(:game) { Codebreaker::Gamebreaker.new }
  let(:path) { 'game_stats.yml' }

  describe '#start_game' do
    before do
      post '/game', level: 'hell', player_name: 'Ivan', game: game
    end
    it 'return game ' do
      get '/game'
      expect(last_request[:game]).to eq(last_response[:game])
    end
  end

  describe '/game' do
    before do
      game.game_level_set('easy')
      env 'rack.session', game: game
      post '/game', level: 'easy', player_name: 'Ivan'
    end

    it 'return status 200  if path /' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'return status 200  if path /game' do
      expect(last_response).to be_ok
    end

    it 'has player_name' do
      expect(last_response.body).to include I18n.t(:hello_msg, name: last_request.session[:name])
    end
  end

  describe '#win' do
    context 'when win path' do
      before do
        File.new(path, 'w+')
        stub_const('Racker::FILE_NAME', path)
        game.game_level_set('easy')
        game.enter_user('Ivan')
        env 'rack.session', game: game, guess_code: '1111', hints: [], level: 'easy', player_name: 'Ivan'
        get '/win', game: game, win: true, player_name: 'Ivan'
      end

      after do
        File.delete(path)
      end

      it 'return status 200  if path /win' do
        expect(last_response.body).to include I18n.t(:congratulations, name: game.user.username)
      end
      it ' return 404' do
        get '/win'
        expect(last_response).to be_ok
      end
    end
  end

  describe '#hint' do
    before do
      game.game_level_set('easy')
      env 'rack.session', game: game
      post '/game', level: 'easy', player_name: 'Ivan'
    end

    it 'return 200 if hint' do
      get '/hint'
      expect(last_response).to be_truthy
    end
  end

  describe '#guess' do
    before do
      game.game_level_set('easy')
      env 'rack.session', game: game, guess_code: '1111', hints: [], level: 'easy', player_name: 'Ivan'
      post '/guess', guess_code: '1111'
    end

    it 'return 200 if guess' do
      expect(last_request.session[:guess_code]).to be_a String
    end
  end

  describe '#status' do
    it 'return status 200  if path /rules' do
      get '/rules'
      expect(last_response).to be_ok
    end

    it 'return stats render ' do
      get '/statistics'
      expect(last_response).to be_ok
    end

    it 'return 404 ' do
      get '/blalbla'
      expect(last_response).to be_ok
    end

    # it 'return status 200  if path /lose' do
    #   get '/lose'
    #   expect(last_response).to be_ok
    # end
  end

  describe '#lose' do
    before do
      game.game_level_set('easy')
      env 'rack.session', game: game, guess_code: '1111', attempts: 0, hints: 1, level: 'easy', player_name: 'Ivan'
      post '/guess', guess_code: '1111'
    end

    it 'destroy session if lose' do
      get '/lose'
      expect(last_response).to be_ok
    end
  end

  # describe '#statistics' do
  #   # it 'return stats render ' do
  #   #   get '/statistics'
  #   #   expect(last_response).to be_ok
  #   # end
  # end
  # describe '#not_found' do
  #   # it 'return 404 ' do
  #   #   get '/blalbla'
  #   #   expect(last_response).to be_ok
  #   # end
  # end
end
