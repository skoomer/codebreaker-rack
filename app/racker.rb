class Racker
  include RenderHelper
  attr_reader :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @storage_game = Codebreaker::Stats.new
  end

  def response
    path = @request.path

    case path
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
    return not_found_render unless exist?(:game)

    Rack::Response.new do |response|
      return lose unless game_session.attempts.positive?

      @request.session[:guess_code] = game_session.exact_match(@request.params['guess_code'])
      return win if game_session.game_win?

      response.redirect('/game')
    end
  end

  def guess_helper
    return lose unless game_session.attempts.positive?
  end

  def lose
    return not_found_render unless exist?(:game)

    Rack::Response.new(lose_render) do
      destroy_session
    end
  end

  def show_stats
    @request.session[:scores] = @storage_game.sort_stats
    statistics_render
  end

  def win
    return not_found_render unless exist?(:game)

    Rack::Response.new(win_render) do
      @storage_game.save_data(start_game)
      destroy_session
    end
  end

  def game
    return not_found_render unless start_game

    @request.session[:game] ||= start_game
    game_render
  end

  def user_name
    return @request.session[:name] if exist?(:name)

    @request.session[:name] = @request.params['player_name']
  end

  def user_level
    return @request.session[:level] if exist?(:level)

    @request.session[:level] = @request.params['level']
  end

  def user_attempts
    return @request.session[:game].attempts if exist?(:game)

    Codebreaker::Gamebreaker::GAME_LEVEL[user_level.to_sym][:attempts]
  end

  def user_hints
    return @request.session[:game].hints if exist?(:game)

    Codebreaker::Gamebreaker::GAME_LEVEL[user_level.to_sym][:hints]
  end

  def index
    return game_render if exist?(:game)
    menu_render
  end

  def destroy_session
    @request.session.clear
  end

  def used_hints
    return @request.session[:used_hints] if exist?(:used_hints)

    @request.session[:used_hints] = []
  end

  def hints_zero?
    game = start_game
    game.hints.zero?
  end

  def hint
    return not_found_render unless exist?(:game)

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
