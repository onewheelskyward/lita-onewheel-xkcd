require 'sequel'
require 'json'
require_relative '../models/comic'

module Lita
  module Handlers
    class OnewheelXkcd < Handler
      # insert handler code here
      DB = Sequel.connect('postgres://root@localhost:5432/lita_xkcd')

      route /^xkcd$/i,
            :random,
            command: true,
            help: {'xkcd' => 'return a random XKCD comic.'}

      route /xkcd (\w+)/i,
            :find_by_keyword,
            command: true,
            help: {'xkcd (keyword)' => 'return an XKCD comic with the keyword specified.'}

      def find_by_keyword(response)
        keywords = response.matches[0][0]
        puts "select id, data->'img' as img, data->'title' as title, data->'alt' as alt from comics where data->>'title' ilike '%#{keywords}%' order by RANDOM() limit 1"
        row = DB["select id, data->'img' as img, data->'title' as title, data->'alt' as alt from comics where data->>'title' ilike '%#{keywords}%' order by RANDOM() limit 1"][:data]
        comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
        reply_with_comic response, comic
      end

      def random(response)
        row = DB["select id, data->'img' as img, data->'title' as title, data->'alt' as alt from comics order by RANDOM() limit 1"][:data]
        comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
        reply_with_comic response, comic
      end

      def reply_with_comic(response, comic)
        response.reply "\"#{comic.title}\" #{comic.image}"
        # set timer for alt response
      end
      Lita.register_handler(self)
    end
  end
end
