module RenderHelper
  def menu_render
    render('menu.html.erb')
  end

  def game_render
    render('game.html.erb')
  end

  def win_render
    render('win.html.erb')
  end

  def lose_render
    render('lose.html.erb')
  end

  def statistics_render
    render('statistics.html.erb')
  end

  def not_found_render
    render('error404.html.erb')
  end

  def rules_render
    render('rules.html.erb')
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    Rack::Response.new(ERB.new(File.read(path)).result(binding))
  end
end
