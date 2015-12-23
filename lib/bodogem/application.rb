require 'logger'
require 'singleton'

module Bodogem
  class Application
    include 'singleton'
    attr_accessor :router

    def config
      @config ||= Application::Configuration.new
    end

    def configure
      yield config if block_given?
      config.setting
    end

    def client
      @client ||= SlackInterface::Client.new(config.channel)
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
            Application.router = main_router
            client.puts "#{package.title}を終了しました"
          end

          Application.router = game_router
          package.new.start
        end
      end

      Application.router = main_router
      logger.info 'Bodogem::Application.run done.'
      client.start
    end
  end
end
