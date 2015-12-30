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

    def router
      @router ||= Application::Router.new(client)
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
              logger.error "EXCEPTION: #{e.class}(#{e.message}):\n#{e.backtrace[0..5].join("\n")}"
              client.puts "エラーが発生しました。"
            ensure
              router.run
              client.puts "#{package.title}を終了しました。"
            end
          end

          router.stop
        end
      end

      router.run
    end
  end
end
