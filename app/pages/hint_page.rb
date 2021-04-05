module Pages
  class HintPage < Page
    def render
      hint

      redirect_to('/game')
    end

    def hint
      used_hints.push(game_session.code_hints)
    end
  end
end
