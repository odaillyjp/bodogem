module Bodogem
  class Application
    class Router
      attr_reader :mapping

      def initialize(client)
        @mapping = Mapping.new
        @thread = nil
        @client = client
      end

      def run
        return if @thread && @thread.alive?

        @thread = Thread.start do
          loop { dispatch(@client.input.string) }
        end
      end

      def stop
        @thread.exit
        @thread = nil
      end

      private

      def dispatch(text)
        route = @mapping.routes.detect { |route| route[:matcher] === text }
        return unless route
        match_data = route[:matcher].match(text)
        route[:callback].call(match_data)
      end

      class Mapping
        attr_reader :routes

        def initialize
          @routes = []
        end

        def draw(matcher, &block)
          @routes << { matcher: matcher, callback: block }
        end
      end
    end
  end
end
