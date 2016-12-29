require "rack"
require "net/http"
require "uri"
require "nokogiri"

TOKEN = File.read(File.expand_path("~/.auth/pinboard")).strip

app = Proc.new { |env|
  uri = URI.parse("https://api.pinboard.in/v1/posts/all/")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new("https://api.pinboard.in/v1/posts/all/?auth_token=#{TOKEN}")
  response = http.request(request)

  results = Nokogiri(response.body)
  links = (results / 'post').map {|post|
    %{<a href="#{post.attr('href')}">#{post.attr('description')}</a>\n}
  }
  ['200', {'Content-Type' => 'text/html'}, links]
}

Rack::Handler::WEBrick.run app
