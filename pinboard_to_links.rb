require "rack"
require "net/http"
require "uri"
require "nokogiri"

USERNAME, PASSWORD = File.read(File.expand_path("~/.auth/pinboard")).split(" ").map(&:strip)

app = Proc.new { |env|
  uri = URI.parse("https://api.pinboard.in/v1/posts/all/")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth USERNAME, PASSWORD
  response = http.request(request)

  results = Nokogiri(response.body)
  links = (results / 'post').map {|post|
    %{<a href="#{post.attr('href')}">#{post.attr('description')}</a>\n}
  }
  ['200', {'Content-Type' => 'text/html'}, links]
}

Rack::Handler::WEBrick.run app
