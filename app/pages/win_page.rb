module Pages
  class WinPage < Page
    def render
      return redirect_to('/') unless exist?(:game)

      storage_game.save_data(game_session)

      super
    end

    def storage_game
      Codebreaker::Stats.new
    end

    def template_path
      'win.html.erb'
    end
  end
end
