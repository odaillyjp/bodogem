module Bodogem
  class Application
    class Router
      def initialize
        @mapping = Mapping.new
      end

      def dispatch(text)
        route = @mapping.routes.detect { |route| route[:matcher] === text }
        return unless route
        match_data = route[:matcher].match(text)
        route[:callback].call(match_data)
      end

      def switch(mapping = Mapping.new)
        mapping.instance_eval(yield) if block_given?
        @mapping = mapping
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
