I18n.load_path << Dir["#{File.expand_path('app/config/locales')}/*.yml"]
I18n.config.available_locales = :en
