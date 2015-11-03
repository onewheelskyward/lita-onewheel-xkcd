require 'sequel'
require 'json'
require 'pry'
require_relative '../models/comic'

module Lita
  module Handlers
    class OnewheelXkcd < Handler
      # insert handler code here
      DB = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

      route /xkcd\s*(random)?/i,
            :random,
            command: true,
            help: {'xkcd random' => 'return a random XKCD comic.'}

      route /xkcd\s*(random)?/i,
            :random,
            command: true,
            help: {'xkcd random' => 'return a random XKCD comic.'}

      def find_by_keyword(response)
        keywords = response.matches[0][0]
        response.reply "keywords #{keywords}"
      end

      def random(response)
        row = DB["select id, data->'img' as img, data->'title' as title, data->'alt' as alt from comics order by RANDOM() limit 1"][:data]
        comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
        response.reply "\"#{comic.title}\" #{comic.image}"
      end
      Lita.register_handler(self)
    end
  end
end
