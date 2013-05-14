require 'hobbit'
require './lib/map'

class App < Hobbit::Base
  include Hobbit::Render
  
  map = Map.new('data/berlin_bike_map.mbtiles')
  missing = File.open('data/missing.png').read
  
  get '/' do
    render 'views/map.html.erb', map: map
  end
  
  get '/tiles/:zoom/:column/:row' do
    z = request.params[:zoom].to_i
    x = request.params[:column].to_i
    y = request.params[:row].to_i

    response.headers['Content-Type'] = 'image/png'
    map.get_tile(z, x, y) || missing
  end
end