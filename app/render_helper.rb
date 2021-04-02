module RenderHelper
  NOT_FOUND = 404

  PAGES = {
    menu_page: 'menu.html.erb',
    game_page: 'game.html.erb',
    win_page: 'win.html.erb',
    lose_page: 'lose.html.erb',
    stats_page: 'statistics.html.erb',
    not_found_page: 'error404.html.erb',
    rules_page: 'rules.html.erb'
  }.freeze

  def not_found
    Rack::Response.new(render(PAGES[:not_found_page]), NOT_FOUND)
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    Rack::Response.new(ERB.new(File.read(path)).result(binding))
  end
end
