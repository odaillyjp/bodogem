module Bodogem
  class Application
    class Router
      attr_reader :mapping

      def initialize(client)
        @mapping = Mapping.new
        @thread = nil
        @client = client
      end

      def run(daemon: false)
        block = lambda do
          text = nil
          route = nil

          loop do
            text = listen_to_message
            route = @mapping.detect(text)
            break if route
          end

          result = dispatch(text, route)
          return block.call if route[:opts] && route[:opts][:continue]
          result
        end

        return Thread.start(&block) if daemon
        block.call
      end

      private

      def listen_to_message
        @client.input.string
      end

      def dispatch(text, route)
        match_data = route[:matcher].match(text)
        route[:callback].call(match_data)
      end

      class Mapping
        def initialize
          @routes = []
        end

        def draw(matcher, opts = {}, &block)
          @routes << { matcher: matcher, opts: opts, callback: block }
        end

        def detect(text)
          @routes.detect { |router| router[:matcher] === text }
        end
      end
    end
  end
end
