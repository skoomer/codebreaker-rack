module RenderHelper
  def menu_render
    Rack::Response.new(render('menu.html.erb'))
  end

  def game_render
    Rack::Response.new(render('game.html.erb'))
  end

  def win_render
    Rack::Response.new(render('win.html.erb'))
  end

  def lose_render
    Rack::Response.new(render('lose.html.erb'))
  end

  def statistics_render
    Rack::Response.new(render('statistics.html.erb'))
  end

  def not_found_render
    Rack::Response.new(render('error404.html.erb'))
  end

  def rules_render
    Rack::Response.new(render('rules.html.erb'))
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
