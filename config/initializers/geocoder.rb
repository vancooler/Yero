# config/initializers/geocoder.rb
Geocoder.configure(

  # geocoding service (see below for supported options):
  :lookup => :bing,

  # IP address geocoding service (see below for supported options):
  :ip_lookup => :maxmind,

  # to use an API key:
  :api_key => " AooRDsQLGQsWk9HX9nPxQN9QYLA7nNdzha9JmXb6IwmcLcrxGv8WTdNTYCKzxCcU ",

  # geocoding service request timeout, in seconds (default 3):
  :timeout => 5,

  # set default units to kilometers:
  :units => :km,

  # # caching (see below for details):
  # :cache => Redis.new,
  # :cache_prefix => "..."
)