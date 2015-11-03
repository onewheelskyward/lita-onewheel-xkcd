require 'sequel'
require 'rest-client'
require 'pry'

DB = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

# DB.create_table :comics do
#   primary_key :id
#   Json :data
# end

max_id = DB[:comics].max(:id) || 1

puts "max_id: #{max_id}"
db_comics = DB[:comics]

top_response = RestClient.get 'http://xkcd.com/info.0.json'
top_json = JSON.parse top_response
puts top_json['num']

for num in max_id..top_json['num'] do
  if num == 404
    puts '404!'
    db_comics.insert(data: '{"status":"not found"}')
    next
  end
  response = RestClient.get "http://xkcd.com/#{num}/info.0.json"
  db_comics.insert(data: response)
  puts "#{num}/#{top_json['num']}"
end

