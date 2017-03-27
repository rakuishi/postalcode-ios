# http://zipcloud.ibsnet.co.jp/

require 'csv'
require 'sqlite3'
require 'nkf'

def nkf(str)
  NKF.nkf('-W -w -X -m0 -Z1 -h1', str)
end

db = SQLite3::Database.new('data.sqlite')
db.execute('CREATE TABLE data (postal_code varchar(16), state_h varchar(16), city_town_h varchar(16), street_h varchar(16), state_k varchar(16), city_town_k varchar(16), street_k varchar(16));')
db.execute('CREATE INDEX idx on data(postal_code, state_k, city_town_k, street_k);')

CSV.read('x-ken-all.csv', encoding: 'Shift_JIS:UTF-8', headers: false).each do |data|
  next if data[2].length == 0

  postal_code = data[2]
  state_h = nkf(data[3])
  city_town_h = nkf(data[4])
  street_h = nkf(data[5])
  state_k = data[6]
  city_town_k = data[7]
  street_k = data[8]

  db.execute('INSERT INTO data (postal_code, state_h, city_town_h, street_h, state_k, city_town_k, street_k) values (?, ?, ?, ?, ?, ?, ?)', postal_code, state_h, city_town_h, street_h, state_k, city_town_k, street_k)
  print '.'
end

db.close
