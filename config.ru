require_relative 'autoloader'

use Rack::Reloader
use Rack::Static, urls: ['/stylesheets', '/assets'], root: 'public'
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 2_592_000,
                           secret: 'change_me',
                           old_secret: 'also_change_me'

run Racker
