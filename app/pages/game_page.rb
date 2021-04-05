module Pages
  class GamePage < Page
    def render
      return redirect_to('/win') if game_session.game_win?
      return redirect_to('/lose') unless game_session.attempts.positive?

      super
    end

    def hints_zero?
      game_session.hints.zero?
    end

    def template_path
      'game.html.erb'
    end
  end
end
