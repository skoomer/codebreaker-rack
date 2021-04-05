module Pages
  class LosePage < Page
    def render
      return redirect_to('/game') if game_session.attempts.positive?

      super
    end

    def template_path
      'lose.html.erb'
    end
  end
end
