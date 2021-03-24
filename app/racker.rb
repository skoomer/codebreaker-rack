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
    case @request.path
    when '/' then index
    when '/game' then game
    when '/rules' then rules_render
    when '/lose' then lose
    when '/win' then win
    else response_helper
    end
  end

  def response_helper
    path = @request.path

    case path
    when '/hint' then hint
    when '/guess' then guess
    when '/statistics' then show_stats
    else not_found_render
    end
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

  def game
    return index unless start_game

    @request.session[:game] ||= start_game
    game_render
  end

  def index
    return game_render if exist?(:game)

    menu_render
  end

  def destroy_session
    @request.session.clear
  end

  def hints_zero?
    game = start_game
    game.hints.zero?
  end

  def hint
    return index unless exist?(:game)

    Rack::Response.new do |response|
      start_game
      return game_render if hints_zero?

      used_hints.push(game_session.code_hints)
      response.redirect('/game')
    end
  end

  def exist?(param)
    @request.session.key?(param)
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

  def level
    @request.params['level']
  end

  def game_session
    @request.session[:game]
  end

  def difficulty_player(game)
    game_level = case level
                 when I18n.t(:easy, scope: [:difficulty]) then :easy
                 when I18n.t(:medium, scope: [:difficulty]) then :medium
                 when I18n.t(:hell, scope: [:difficulty]) then :hell
                 end

    game.game_level_set(game_level)
  end
end
