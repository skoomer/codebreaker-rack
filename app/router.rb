class Router
  attr_reader :request

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def call
    routes = {
      '/' => Pages::HomePage,
      '/game' => Pages::GamePage,
      '/rules' => Pages::RulesPage,
      '/statistics' => Pages::StatisticsPage,
      '/reset' => Pages::ResetPage,
      '/win' => Pages::WinPage,
      '/lose' => Pages::LosePage,
      '/guess' => Pages::GuessPage,
      '/hint' => Pages::HintPage,
      '/404' => Pages::NotFoundPage
    }

    page = routes[request.path]&.new(request)

    return redirect_to('/') if need_session?(page)

    page&.render || Pages::NotFoundPage.new(request).render
  end

  private

  def need_session?(page)
    !game_session && !page.is_a?(Pages::HomePage) \
    && !page.is_a?(Pages::RulesPage) \
    && !page.is_a?(Pages::StatisticsPage) \
    && !page.is_a?(Pages::WinPage)
    # && !page.is_a?(Pages::NotFoundPage)
  end

  def game_session
    request.session[:game]
  end

  def redirect_to(path)
    Rack::Response.new { |response| response.redirect(path) }
  end
end
