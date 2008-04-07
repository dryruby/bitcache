require 'optparse'

module Bitcache::CLI
  class Base
    @@cmd = nil

    def self.inherited(child) #:nodoc:
      at_exit { child.new(ARGV).send(:run) }
    end

    def self.banner(text)
      @@opts ||= OptionParser.new
      @@opts.banner = text
    end

    def self.option(*args)
      @@opts ||= OptionParser.new
      block = args.pop
      @@opts.on(*args, &block)
    end

    def self.help(command, text)
      @@help ||= {}
      @@help[command] = text
    end

    help :help, "Display a list of all supported commands."

    def help(command = nil)
      puts @@opts.to_s
      puts
      @@help.each do |cmd, text|
        if command.nil? || command == cmd.to_s
          puts "    #{cmd.to_s.ljust(32)} #{text}"
        end
      end
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
          @@opts.parse!(@argv)
        rescue OptionParser::ParseError => e
          warn "#{File.basename($0)}: #{e.message}"
          abort @@opts.to_s
        end
      end

      def run
        cmd = !@@cmd.nil? ? @@cmd.to_sym : (!@argv.empty? ? @argv.shift.to_sym : :hint)
        send(cmd, *@argv)
      end

  end
end
