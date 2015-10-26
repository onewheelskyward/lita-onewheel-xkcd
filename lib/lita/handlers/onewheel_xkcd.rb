require 'sequel'

module Lita
  module Handlers
    class OnewheelXkcd < Handler
      # insert handler code here
      route /xkcd ([a-zA-Z,.\- ]+)/,
            :find_by_keyword,
            command: true,
            help: ''

      def find_by_keyword(response)
        keywords = response.matches[0][0]
        response.reply "keywords #{keywords}"
      end
      Lita.register_handler(self)
    end
  end
end
