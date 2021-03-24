require_relative 'autoloader'

use Rack::Reloader
use Rack::Static, urls: ['/stylesheets'], root: 'public'
use Rack::Static, urls: ['/bootstrap', '/jquery'], root: 'node_modules'

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 2_592_000,
                           secret: 'change_me',
                           old_secret: 'also_change_me'

run Racker
