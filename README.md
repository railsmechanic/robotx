# Robotx
Robotx _(pronounced "robotex")_ is a simple but powerful parser for robots.txt files.
It offers a bunch of features which allows you to check whether an URL is allowed/disallowed to be visited by a crawler.


## Features

- Maintains lists for allowed/disallowed URLs
- Simple method to check whether an URL or just a path is allowed to be visited
- Show all user agents covered by the robots.txt
- Get the 'Crawl-Delay' for a website
- Support for sitemap(s)

## Installation
### With Bundler
Just add to your Gemfile
~~~ruby
gem 'robotx'
~~~

### Without Bundler
If you're not using Bundler just execute on your commandline
~~~bash
$ gem install robotx
~~~

## Usage
### Support for different user agents
Robotx can be initialized with a special user agent. The default user agent is `*`.
**Please note:** All method results depends on the user agent Robotx was initialized with.
~~~ruby
require 'robotx'

# Initialize with the default user agent '*'
robots_txt = Robotx.new('https://github.com')
robots_txt.allowed  # => ["/humans.txt"]

# Initialize with 'googlebot' as user agent
robots_txt = Robotx.new('https://github.com', 'googlebot')
robots_txt.allowed # => ["/*/*/tree/master", "/*/*/blob/master"]
~~~

### Check whether an URL is allowed to be indexed
~~~ruby
require 'robotx'

robots_txt = Robotx.new('https://github.com')
robots_txt.allowed?('/humans.txt')  # => true
robots_txt.allowed?('/')  # => false

# The allowed? method can also handle arrays or URIs/paths
robots_txt.allowed?(['/', '/humans.txt'])  # => {"/"=>false, "/humans.txt"=>true}
~~~

### Get all allowed/disallowed URLs
~~~ruby
require 'robotx'

robots_txt = Robotx.new('https://github.com')
robots_txt.allowed  # => ["/humans.txt"]
robots_txt.disallowed  # => ["/"]
~~~

### Get additional information
~~~ruby
require 'robotx'

robots_txt = Robotx.new('https://github.com')
robots_txt.sitemap  # => []
robots_txt.crawl_delay  # => 0
robots_txt.user_agents  # => ["googlebot", "baiduspider", ...]
~~~

## Todo
- Add tests
