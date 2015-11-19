require 'sequel'
require 'json'
require_relative '../models/comic'

module Lita
  module Handlers
    class OnewheelXkcd < Handler
      config :db_host, required: true, default: 'localhost'
      config :db_name, required: true, default: 'lita_xkcd'
      config :db_user, required: true, default: 'root'
      config :db_pass, required: true, default: ''
      config :db_port, required: true, default: 5432

      route /^xkcd$/i,
            :random,
            command: true,
            help: {'xkcd' => 'return a random XKCD comic.'}

      route /^xkcd ([a-zA-Z ]+)/i,
            :find_by_keyword,
            command: true,
            help: {'xkcd (keyword)' => 'return an XKCD comic with the keyword(s) specified.'}

      route /^xkcd (\d+)/i,
            :find_by_number,
            command: true,
            help: {'xkcd (keyword)' => 'return an XKCD comic with the keyword(s) specified.'}

      route /^xkcd prev/i,
            :find_prev,
            command: true,
            help: {'xkcd prev' => 'return the previous XKCD comic by date.'}

      route /^xkcd prev/i,
            :find_next,
            command: true,
            help: {'xkcd prev' => 'return the next XKCD comic by date.'}

      def find_by_keyword(response)
        db = init_db
        keywords = response.matches[0][0]
        result = db["select
          id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where data->>'title' ilike ? order by RANDOM() limit 1", "%#{keywords}%"]
        if row = result[:data]
          comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
          reply_with_comic response, comic
        end
      end

      def find_by_number(response)
        db = init_db
        number = response.matches[0][0]
        result = db["select
          id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where id = ?", number]
        if row = result[:data]
          comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
          reply_with_comic response, comic
        end
      end

      def random(response)
        db = init_db
        row = db["select
          id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          order by RANDOM()
          limit 1"][:data]
        comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
        reply_with_comic response, comic
      end

      ##
      # Helper function to display comic and set timer for alt tag.
      #
      def reply_with_comic(response, comic)
        set_state comic, response.user
        response.reply "\"#{comic.title}\" #{comic.image}"
        after(9) do |timer|
          response.reply comic.alt
        end
      end

      ##
      # Save the state oh the recently displayed comic by user.
      #
      def set_state(comic, user)
        db = init_db
        state = db[:state]
        user_state = state.where(:user => user.name)
        if user_state
          user_state.update(:last_comic => comic.id)
        else
          state.insert(user: user.name, last_comic: comic.id)
        end
      end

      ##
      # Grab the user's last_comic for informational purposes.
      #
      def get_last_comic(user)
        db = init_db
        state = db[:state].filter(:user => user.name)
        state[:last_comic]
      end

      def init_db
        Sequel.connect("postgres://#{config.db_user}:#{config.db_pass}@#{config.db_host}:#{config.db_port}/#{config.db_name}")
      end
      Lita.register_handler(self)
    end
  end
end
