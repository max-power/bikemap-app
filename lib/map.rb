require 'sqlite3'

class Map
  attr_accessor :db, :name, :center, :zoom, :attribution, :bounds, :version
  
  def initialize(filename)
    self.db = SQLite3::Database.new(filename)
    read_meta_data
  end
  
  def get_tile(z, x, y)
    # Convert from ZXY to TMS
    y = (1 << z) - 1 - y
    db.get_first_value('SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?;', z, x, y)
  end  
  
  private
  def read_meta_data
    data = Hash[*db.execute('SELECT * FROM metadata').flatten]
    self.name = data['name']
    self.attribution = data['attribution']
    self.version = data['version']
    lng, lat, default_zoom = data['center'].split(',')
    self.center = { lat: lat.to_f, lng: lng.to_f }
    self.zoom = { default: default_zoom.to_i, min: data['minzoom'].to_i, max: data['maxzoom'].to_i }
    bounds = data['bounds'].split(',')
    self.bounds = {
      sw: { lat: bounds[1].to_f, lng: bounds[0].to_f },
      ne: { lat: bounds[3].to_f, lng: bounds[2].to_f }
    }
  end
end