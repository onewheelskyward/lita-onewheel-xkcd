require 'sequel'
require 'rest-client'

DB = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

# DB.create_table :comics do
#   primary_key :id
#   Json :data
# end

db_comics = DB[:comics]

top_response = RestClient.get 'http://xkcd.com/info.0.json'
top_json = JSON.parse top_response
puts top_json['num']

for num in 405..top_json['num'] do
  response = RestClient.get "http://xkcd.com/#{num}/info.0.json"
  db_comics.insert(data: response)
  puts "#{num}/#{top_json['num']}"
end

