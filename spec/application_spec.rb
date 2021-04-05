RSpec.describe Application do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  let(:game) { Codebreaker::Gamebreaker.new }
  let(:enter_guess_code) { '1' * Codebreaker::Constants::SECRET_CODE_LENGHT }
  let(:zero_attempts) { 0 }
  let(:level) { 'easy' }
  let(:player_name) { 'Ivan' }
  let(:win_true) { true }

  let(:path) { 'game_stats.yml' }

  describe '#RulesPage' do
    it 'return status 200 ' do
      get '/rules'
      expect(last_response.status).to eq 200
    end
  end

  describe '#HomePage' do
    describe '.init_game_session' do
      it 'return game' do
        game.game_level_set(level)
        game.enter_user(player_name)
        env 'rack.session', game: game
        get '/', level: level, player_name: player_name
        expect(last_request.session[:game]).to eq(game)
      end
    end

    describe '.render' do
      before do
        game.game_level_set(level)
        game.enter_user(player_name)
        env 'rack.session', game: game
        post '/', level: level, player_name: player_name
      end

      it 'return game  if request post' do
        get '/game'

        expect(last_request.session[:game]).to eq(game)
      end
    end
  end

  describe '#ResetPage' do
    context 'when call reset page' do
      before do
        game.game_level_set(level)
        game.enter_user(player_name)
        env 'rack.session', game: game
        post '/reset', game: game
      end

      it 'redirect home page' do
        get '/'
        expect(last_response.status).to eq 302
      end
    end
  end

  describe '#NotFoundPage' do
    before do
      game.game_level_set(level)
      game.enter_user(player_name)
      env 'rack.session', game: game
    end

    it 'return not found page' do
      get '/dasdas'
      expect(last_response.status).to eq 200
    end
  end

  describe '#LosePage' do
    context 'if game exist'
    before do
      game.game_level_set(level)
      game.enter_user(player_name)
      env 'rack.session', game: game, player_name: player_name
    end

    it 'redirect game' do
      get '/lose'
      expect(last_response.status).to eq 302
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

  describe '#StatisticsPage' do
    before do
      game.game_level_set(level)
      env 'rack.session', game: game, hints: [],
                          guess_code: enter_guess_code, level: level,
                          player_name: player_name
    end

    it 'return 200 ' do
      get '/statistics'
      expect(last_response).to be_ok
    end
  end

  describe 'with page not found' do
    it 'redirect ' do
      get '/dsds'
      expect(last_response.status).to eq 302
    end
  end

  describe '#HintPage' do
    before do
      game.game_level_set(level)
      game.enter_user(player_name)
      env 'rack.session', game: game, used_hints: []
      post '/hint', level: level, player_name: player_name, used_hints: game.code_hints
    end

    it 'return 200' do
      get '/game'
      expect(last_response).to be_truthy
    end
  end
end
