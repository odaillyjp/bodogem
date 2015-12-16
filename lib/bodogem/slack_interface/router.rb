module Bodogem
  module SlackInterface
    class Router
      def initialize
        @routes = []
      end

      def draw(matcher, &block)
        @routes << { matcher: matcher, callback: block }
      end

      def dispatch(text)
        route = @routes.detect { |route| route[:matcher].match(text) }
        return unless route
        match_data = route[:matcher].match(text)
        route[:callback].call(match_data)
      end
    end
  end
end
