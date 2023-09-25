# Verse::Http

HTTP Server for the Verse framework

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add verse-http

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install verse-http

## Usage

Add the plugin to your project in your `config.yml` file:

```yaml
# ...
plugins:
  - name: http
```

For new project, verse generator should detect the gem once installed via `gem` command and offer you the possibility to use it.

Example code should be generated during the creation of your new project.

For usage, you have now access to the `on_http` hook on your expositions.

## Simple Example

Here is a simple config.ru example:

```ruby
# in config.ru

require "verse/core"
require "verse/http"

# a) Initialize Verse:
Verse.start(:server, config_path: "config.yml")

# b) Register your exposition:

class MyExposition < Verse::Exposition::Base
  expose on_http(:get, "example", auth: nil)
  def example
    {output: "hello world!"}
  end
end

MyExposition.register

# c) run using rack.
run Verse::Http::Server
```

Assuming you use Puma webserver:

```bash
$ bundle exec puma
```

## Complex Example

Using the generator or checking the sample folder will give you more
context on how to use Verse HTTP in a bigger project.

The flow is:
1. Init verse framework
2. Load your expositions classes
3. Register them
4. Run the server

## Add Cookies support

1. Add the Gem `sinatra-contrib` in your Gemfile.
2. Create an initializer file (e.g. `config/initializers/cookies.rb`) and add:

```ruby
require "sinatra/cookies"

Verse::Http::Server.helpers(Sinatra::Cookies)
```