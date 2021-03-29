module RackerHelper
  include RenderHelper
  
  def show_stats
    return game if exist?(:game)

    @request.session[:scores] = @storage_game.sort_stats
    render(PAGES[:stats_page])
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

  def used_hints
    return @request.session[:used_hints] if exist?(:used_hints)

    @request.session[:used_hints] = []
  end

  def lose
    return index unless exist?(:game)

    Rack::Response.new(render(PAGES[:lose_page])) do
      destroy_session
    end
  end

  def rules
    render(PAGES[:rules_page])
  end

  def win
    return index unless exist?(:game)

    Rack::Response.new(render(PAGES[:win_page])) do
      @storage_game.save_data(start_game)
      destroy_session
    end
  end
end
