module Pages
  class StatisticsPage < Page
    attr_reader :request

    def scores
      storage_game.sort_stats
    end

    def storage_game
      Codebreaker::Stats.new
    end

    def template_path
      'statistics.html.erb'
    end
  end
end
