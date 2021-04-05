module Pages
  class GuessPage < Page
    def render
      return redirect_to('/lose') unless game_session.attempts.positive?

      guess_helper

      redirect_to '/game'
    end

    def guess_helper
      guess_code = request.params['guess_code']

      return redirect_to('/game') if  guess_code.nil?

      @request.session[:guess_code] = game_session.exact_match(guess_code)

      return redirect_to('/win') if game_session.game_win?
      return redirect_to('/lose') unless game_session.attempts.positive?
    end
  end
end
