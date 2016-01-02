require 'logger'

module Bodogem
  class Application
    def config
      @config ||= Application::Configuration.new
    end

    def configure
      yield config if block_given?
      config.setting
    end

    def client
      @client ||= SlackInterface::Client.new(channel_name: config.channel, token: config.token)
    end

    def packages
      @packages ||= []
    end

    def logger
      config.logger
    end

    def run(dry: false)
      Performance::Benchmarker.log(title: 'Completed Application#setup in') { setup }
      client.start unless dry
    end

    private

    def setup
      packages.each do |package|
        router.mapping.draw "#{package.title}をはじめる" do
          client.puts "#{package.title}を準備しています..."

          Thread.start do
            begin
              package.start
            rescue => e
              logger.error "#{e.class}: #{e.message}\n{\"module\"=>\"#{package}\"}\n#{e.backtrace[0..5].join("\n")}"
              client.puts "エラーが発生しました。"
            ensure
              run_router_as_daemon
              client.puts "#{package.title}を終了しました。"
            end
          end
        end
      end

      run_router_as_daemon
    end

    def router
      @router ||= Application::Router.new(client)
    end

    def run_router_as_daemon
      return if @thread && @thread.alive?
      @thread = router.run(daemon: true)
    end
  end
end
