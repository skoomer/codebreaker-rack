RSpec.describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  let(:game) { Codebreaker::Gamebreaker.new }
  let(:enter_guess_code) { '1' * Codebreaker::Constants::SECRET_CODE_LENGHT }
  let(:zero_attempts) { 0 }
  let(:level) { 'easy' }
  let(:player_name) { 'Ivan' }
  let(:win_true) { true }

  let(:path) { 'game_stats.yml' }

  describe '#start_game' do
    it 'empty params' do
      get '/game'
      expect(last_request.params.empty?).to eq(true)
    end

    context 'with game' do
      before do
        game.game_level_set(level)
        game.enter_user(player_name)
        env 'rack.session', game: game
        post '/game', game: game
      end

      it 'sets game session' do
        get '/game'

        expect(last_request.session[:game]).to eq(game)
      end

      it 'returns status 200' do
        expect(last_response.status).to eq 200
      end
    end
  end

  describe '/game' do
    before do
      game.game_level_set(level)
      env 'rack.session', game: game
      get '/game', level: level, player_name: player_name
    end

    it 'return status 200  if path /' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'return status 200' do
      expect(last_response).to be_ok
    end

    it 'has player_name' do
      expect(last_response.body).to include I18n.t(:hello_message, name: player_name)
    end
  end

  describe '#win' do
    context 'when win path' do
      before do
        File.new(path, 'w+')
        stub_const('Racker::FILE_NAME', path)
        game.game_level_set(level)
        game.enter_user(player_name)
        env 'rack.session', game: game, guess_code: enter_guess_code, hints: [], level: level, player_name: player_name
        get '/win', game: game, win: win_true, player_name: player_name
      end

      after do
        File.delete(path)
      end

      it 'return congratulations message if game win' do
        expect(last_response.body).to include I18n.t(:congratulations, name: player_name)
      end

      it ' return 200' do
        get '/win'
        expect(last_response.status).to eq 200
      end
    end
  end

  describe '#hint' do
    before do
      game.game_level_set(level)
      env 'rack.session', game: game
      post '/game', level: level, player_name: player_name
    end

    it 'return 200' do
      get '/hint'
      expect(last_response).to be_truthy
    end
  end

  describe '#guess' do
    let(:plus) { '++++' }
    let(:code) { [1, 1, 1, 1] }

    before do
      game.game_level_set(level)
      game.secret_code = code
      env 'rack.session', game: game, secret_code: code, guess_code: enter_guess_code, hints: [], level: level,
                          player_name: player_name
      post '/guess', guess_code: enter_guess_code
    end

    it 'return response exact guess' do
      get '/game'
      expect(game.exact_match(last_request.session[:guess_code])).to eq plus
    end
  end

  describe '#response status code' do
    describe '.rules' do
      it 'return status 200  if path /rules' do
        get '/rules'
        expect(last_response).to be_ok
      end
    end

    describe '.statistics' do
      before do
        game.game_level_set(level)
        env 'rack.session', game: game, guess_code: enter_guess_code, hints: [], level: level,
                            player_name: player_name
      end

      it 'return 200 ' do
        get '/statistics'
        expect(last_response).to be_ok
      end
    end

    context 'with page not found' do
      let(:response) { get '/blalbla' }

      it 'return 404 ' do
        response
        expect(last_response.status).to eq 404
      end
    end
  end

  describe '#lose' do
    before do
      game.game_level_set(level)
      env 'rack.session', game: game, guess_code: enter_guess_code, attempts: zero_attempts,
                          level: game.game_level.difficulty, player_name: player_name
      post '/guess', guess_code: enter_guess_code
    end

    it 'destroy session if lose' do
      get '/lose'
      expect(last_request.session).to be_empty
    end
  end
end
