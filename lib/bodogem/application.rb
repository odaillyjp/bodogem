require 'logger'

module Bodogem
  class Application
    attr_accessor :router

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

    def run
      main_router = Application::Router.new

      packages.each do |package|
        main_router.draw /\A#{package.title}をはじめる\z/ do
          client.puts "#{package.title}を準備しています..."
          game_router = Application::Router.new

          game_router.draw /\A#{package.title}をおわる\z/ do
            self.router = main_router
            client.puts "#{package.title}を終了しました"
          end

          self.router = game_router
          package.new.start
        end
      end

      self.router = main_router
      logger.info 'Bodogem::Application.run done.'
      client.start
    end
  end
end
