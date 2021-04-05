module Pages
  class HomePage < Page
    def render
      init_game_session!(request) if request.post?

      return redirect_to('/game') if game_session

      super
    end

    private

    def init_game_session!(request)
      player_name, level = request.params.values_at('player_name', 'level')

      game = Codebreaker::Gamebreaker.new

      game.enter_user(player_name)
      game.game_level_set(level)

      request.session[:used_hints] = []
      request.session[:game] = game
    end

    def template_path
      'menu.html.erb'
    end
  end
end
