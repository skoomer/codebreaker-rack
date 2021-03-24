require_relative 'autoloader'

use Rack::Reloader
# use Rack::Static, urls: ['/stylesheets', '/assets','/node_modules'], root: 'public'
use Rack::Static, urls: ['/public', '/node_modules']

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 2_592_000,
                           secret: 'change_me',
                           old_secret: 'also_change_me'

run Racker
