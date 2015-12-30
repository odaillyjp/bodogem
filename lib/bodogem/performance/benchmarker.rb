require 'benchmark'

module Bodogem
  module Performance
    module Benchmarker
      def self.log(title: 'Completed in', logger: Bodogem.application.logger)
        result = nil
        seconds = Benchmark.realtime { result = yield }
        logger.info "#{title} #{sprintf("%.2f", seconds * 1000)}ms"
        result
      end
    end
  end
end
