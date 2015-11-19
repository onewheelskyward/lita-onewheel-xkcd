require 'sequel'

db = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

db.create_table :comics do
  primary_key :id
  Json :data
end

db.create_table :state do
  String :user
  int :last_comic
end
