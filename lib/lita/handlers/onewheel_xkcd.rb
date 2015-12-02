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
      config :alt_delay, default: 9

      route /^xkcdupdate$/,
            :update,
            command: true
            # admin_only

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
            help: {'xkcd (number)' => 'return an XKCD comic by it\'s number (somewhere between 1 and 1600).'}

      route /^xkcd prev/i,
            :find_prev,
            command: true,
            help: {'xkcd prev' => 'return the previous XKCD comic by date.'}

      route /^xkcd next/i,
            :find_next,
            command: true,
            help: {'xkcd prev' => 'return the next XKCD comic by date.'}

      route(/^xkcd (\d{1,2})[-\/](\d{1,2})[-\/](\d{2,4})$/i,
            :find_by_mdy,
            command: true,
            help: { 'xkcd 1/1/2014' => 'Get an XKCD comic for a m/d/y date.'})

      route(/^xkcd (\d{2,4})-(\d{1,2})-(\d{1,2})$/i,
            :find_by_ymd,
            command: true,
            help: { 'xkcd 2014-1-1' => 'Get an XKCD comic for a y-m-d date.'})

      ##
      # Search the title for a string, and return the comic.
      #
      def find_by_keyword(response)
        db = init_db
        keywords = response.matches[0][0]
        result = db["
          select id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where data->>'title' ilike ? order by RANDOM() limit 1", "%#{keywords}%"]
        if row = result[:data]
          comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
          reply_with_comic response, comic
        end
      end

      ##
      # Search for the date, and return the comic.
      #
      def find_by_date(month, day, year)
        db = init_db
        result = db["
          select id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where data->>'month' = ? and data->>'day' = ? and data->>'year' = ? limit 1", month.to_s, day.to_s, year.to_s]
        if row = result[:data]
          Comic.new(row[:id], row[:img], row[:title], row[:alt])
        end
      end

      ##
      # Find by xkcd id.
      #
      def find_by_number(response)
        db = init_db
        number = response.matches[0][0]
        result = db["
          select id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where id = ?", number]
        if row = result[:data]
          comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
          reply_with_comic response, comic
        end
      end

      ##
      # Get a random comic
      #
      def random(response)
        db = init_db
        row = db["
          select id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          order by RANDOM()
          limit 1"
        ][:data]
        comic = Comic.new(row[:id], row[:img], row[:title], row[:alt])
        reply_with_comic response, comic
      end

      ##
      # Find the next comic based on user state
      #
      def find_next(response)
        db = init_db
        if last_comic = get_last_comic(response.user)
          last_comic += 1
          comic = get_comic_by_id(db, last_comic)
          reply_with_comic response, comic
        end
      end

      ##
      # Find the previous comic based on user state
      #
      def find_prev(response)
        db = init_db
        if last_comic = get_last_comic(response.user)
          last_comic -= 1
          comic = get_comic_by_id(db, last_comic)
          reply_with_comic response, comic
        end
      end

      def find_by_ymd(response)
        date = Date.civil(response.match_data[1].to_i, response.match_data[2].to_i, response.match_data[3].to_i)
        comic = find_by_date(date.month, date.day, date.year)
        reply_with_comic response, comic
      end

      def find_by_mdy(response)
        date = Date.civil(response.match_data[3].to_i, response.match_data[1].to_i, response.match_data[2].to_i)
        comic = find_by_date(date.month, date.day, date.year)
        reply_with_comic response, comic
      end

      ##
      # Grab the comic object by xkcd id (which is also db id)
      #
      def get_comic_by_id(db, last_comic)
        row = db["
          select id, data->'img' as img, data->'title' as title, data->'alt' as alt
          from comics
          where id = ?", last_comic][:data]

        Comic.new(row[:id], row[:img], row[:title], row[:alt])
      end

      ##
      # Helper function to display comic and set timer for alt tag.
      #
      def reply_with_comic(response, comic)
        if comic
          set_state comic, response.user
          response.reply "XKCD #{comic.id} \"#{comic.title}\" #{comic.image}"
          after(config.alt_delay) do |timer|
            response.reply comic.alt
          end
        end
      end

      ##
      # Save the state oh the recently displayed comic by user.
      #
      def set_state(comic, user)
        db = init_db
        state = db[:state]
        user_state = state.where(:user => user.name)
        if user_state.count > 0
          log.debug 'Updating state!'
          user_state.update(:last_comic => comic.id)
        else
          log.debug 'Creating state!'
          state.insert(user: user.name, last_comic: comic.id)
        end
      end

      ##
      # Grab the user's last_comic for informational purposes.
      #
      def get_last_comic(user)
        db = init_db
        dataset = db[:state].where(:user => user.name)
        if dataset.count > 0
          dataset.first[:last_comic]
        else
          log.debug("get_last_comic called with no user state for #{user.name}")
        end
      end

      def update(response)
        db = init_db
        # Check tables? run schema?
        max_id = db[:comics].max(:id) || 1  # Get the last id or start with one.
        top_num = get_top_num
        response.reply "Updating from #{max_id} to #{top_num}!"
        perform_update(max_id + 1, top_num)
      end

      def get_top_num
        top_response = RestClient.get 'http://xkcd.com/info.0.json'
        top_json = JSON.parse top_response
        top_num = top_json['num']
        top_json
      end

      def perform_update(max_id, top_num)
        for num in max_id..top_num do
          if num == 404
            db_comics.insert(data: '{"status":"not found"}')
            next
          end
          response = RestClient.get "http://xkcd.com/#{num}/info.0.json"
          db_comics.insert(data: response)
        end
      end

      def init_db
        Sequel.connect("postgres://#{config.db_user}:#{config.db_pass}@#{config.db_host}:#{config.db_port}/#{config.db_name}")
      end
      Lita.register_handler(self)
    end
  end
end
