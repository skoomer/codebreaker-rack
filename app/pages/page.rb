module Pages
  class Page
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def render
      Rack::Response.new(render_erb(template_path))
    end

    protected

    def template_path
      raise NotImplementedError
    end

    def game_session
      request.session[:game]
    end

    def user_hints
      game_session.hints
    end

    def used_hints
      @request.session[:used_hints]
    end

    def exist?(param)
      @request.session.key?(param)
    end

    def match
      request.session[:match] || ''
    end

    def redirect_to(path)
      Rack::Response.new { |response| response.redirect(path) }
    end

    def render_erb(template)
      path = File.expand_path("../../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end
  end
end
