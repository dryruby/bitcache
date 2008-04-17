require 'optparse'

module Bitcache::CLI
  class Base
    @@cmd = nil

    def self.inherited(child) #:nodoc:
      at_exit { child.new(ARGV).send(:run) }
    end

    def self.banner(text)
      @@options ||= OptionParser.new
      @@options.banner = text
    end

    def self.option(*args)
      @@options ||= OptionParser.new
      block = args.pop
      @@options.on(*args, &block)
    end

    def self.help(command, text)
      @@help ||= {}
      @@help[command] = text
    end

    def self.command(names, args = [], options = {}, &block)
      return if options[:enabled] == false

      names = [names].flatten.map { |name| name.to_sym }
      @@aliases ||= {}
      @@aliases[names.first] = names

      help names.first, options[:help] if options[:help]

      define_method names.first, block
      names[1..-1].each { |name| alias_method name, names.first }
    end

    help :help, "Display a list of all supported commands."

    def help(command = nil)
      puts @@options.to_s
      puts "\nCommands:" unless !command.nil? || @@help.empty?
      @@help.each do |cmd, text|
        if command.nil? || command == cmd.to_s
          puts "    #{cmd.to_s.ljust(32)} #{text}"
        end
      end
      puts
    end

    def hint
      puts "Please specify a command to execute."
      help
    end

    protected

      def initialize(argv)
        $OPTIONS ||= {}
        @argv = argv

        begin
          @@options.parse!(@argv)
        rescue OptionParser::ParseError => e
          warn "#{basename}: #{e.message}"
          abort @@options.to_s
        end
      end

      def run
        Bitcache.load_config!

        cmd = !@@cmd.nil? ? @@cmd.to_sym : (!@argv.empty? ? @argv.shift.to_sym : :hint)
        abort "#{basename}: unknown command '#{cmd}'." unless respond_to?(cmd)
        send(cmd, *@argv)
      end

    private

      #def self.basename() File.basename($0) end
      def basename() File.basename($0) end
      module_function :basename

  end
end
