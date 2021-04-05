module Pages
  class ResetPage < Page
    def render
      clear_game_session!
      redirect_to('/')
    end

    private

    def clear_game_session!
      request.session[:game] = nil
    end
  end
end
