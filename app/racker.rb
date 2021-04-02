class Racker
  include RenderHelper
  include RackerHelper
  attr_reader :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @storage_game = Codebreaker::Stats.new
  end

  def response
    case path
    when '/' then index
    when '/game' then game
    when '/rules' then rules
    when '/lose' then lose
    when '/win' then win
    else response_helper
    end
  end

  def response_helper
    case path
    when '/hint' then hint
    when '/guess' then guess
    when '/statistics' then show_stats
    else not_found
    end
  end

  def path
    @path ||= @request.path
  end

  def guess
    return index unless exist?(:game)

    Rack::Response.new do |response|
      return lose unless game_session.attempts.positive?

      guess_helper
      return win if game_session.game_win?

      response.redirect('/game')
    end
  end

  def guess_helper
    guess_code = @request.params['guess_code']
    return game if guess_code.nil?

    @request.session[:guess_code] = game_session.exact_match(guess_code)
  end

  def index
    return render(PAGES[:game_page]) if exist?(:game)

    render(PAGES[:menu_page])
  end

  def hints_zero?
    game_session.hints.zero?
  end

  def hint
    return index unless exist?(:game)

    Rack::Response.new do |response|
      return render(PAGES[:game_page]) if hints_zero?

      used_hints.push(game_session.code_hints)
      response.redirect('/game')
    end
  end

  def exist?(param)
    @request.session.key?(param)
  end

  def game
    return index unless start_game

    @request.session[:game] ||= start_game
    render(PAGES[:game_page])
  end

  def start_game
    return game_session if exist?(:game)

    return false if @request.params.empty?

    game = Codebreaker::Gamebreaker.new

    game.enter_user(@request.params['player_name'])
    difficulty_player(game)
    game
  end

  private

  def destroy_session
    @request.session.clear
  end

  def level
    @request.params['level']
  end

  def game_session
    @request.session[:game]
  end

  def difficulty_player(game)
    game.game_level_set(level)
  end
end
