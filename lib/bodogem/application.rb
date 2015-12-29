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
      @router ||= Application::Router.new
    end

    def run
      packages.each do |package|
        root_mapping.draw "#{package.title}をはじめる" do
          client.puts "#{package.title}を準備しています..."
          router.switch(package.routes) if package.respond_to?(:routes)

          @package_thread = Thread.start do
            begin
              package.start
            rescue => e
              logger.error "title = #{package.title}, message = #{e}"
              client.puts "エラーが発生しました。\n#{package.title}を終了します..."
            ensure
              switch_root_mapping
              client.puts "#{package.title}を終了しました。"
            end
          end
        end
      end

      switch_root_mapping
      logger.info 'Bodogem::Application.run done.'
      client.start
    end

    def exit_package
      return unless @package_thread

      @package_thread.exit
      @package_thread = nil
    end

    private

    def root_mapping
      @root_mapping ||= Application::Router::Mapping.new
    end

    def switch_root_mapping
      router.switch(root_mapping)
    end
  end
end
