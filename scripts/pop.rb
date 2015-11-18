require 'sequel'
require 'rest-client'

db = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

max_id = db[:comics].max(:id) || 1

puts "max_id: #{max_id}"
db_comics = db[:comics]

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

