require 'open4'

module Bitcache
  module GPG
    class Error < IOError ; end

    OPTIONS = {
      :cipher_algo    => :aes256,
      :digest_algo    => :sha1,
      :compress_algo  => :bzip2,
      :output         => '-',
      :quiet          => true,
      :batch          => true,
    }

    def self.encrypt(input, passphrase, options = {}, &block)
      output = gpg('-c', input, options.merge(:passphrase => passphrase))
      block_given? ? block.call(output) : output.read
    end

    def self.decrypt(input, passphrase, options = {}, &block)
      output = gpg('-d', input, options.merge(:passphrase => passphrase, :no_mdc_warning => true))
      block_given? ? block.call(output) : output.read
    end

    protected

      def self.gpg(command, input, options = {}, &block)
        case
          when input.is_a?(Proc)            # input producer block
            gpg_exec(command, options, &input)

          when input.respond_to?(:realpath) # Pathname
            gpg_exec("#{command} #{escapeshellarg(input.realpath)}", options)

          when input.respond_to?(:read)     # Stream, IO, File
            gpg_exec(command, options) { |stdin| stdin.write input.read } # TODO: 4K chunks

          when input.respond_to?(:to_str)   # String
            gpg_exec(command, options) { |stdin| stdin.write input.to_str }

          else
            raise ArgumentError, input
        end
      end

      def self.gpg_exec(command, options = {}, &block)
        passphrase = options.delete(:passphrase)
        passout, passin = IO.pipe
        options[:passphrase_fd] = passout.fileno

        command = 'gpg ' + (gpg_options(options) + [command]).flatten.join(' ')
        pid, stdin, stdout, stderr = Open4.popen4(command)

        passin.puts passphrase
        passin.close_write

        block.call(stdin) if block_given?
        stdin.close_write

        pid, status = Process.waitpid2(pid)
        raise Error, stderr.read.chomp if status.exitstatus != 0
        stdout
      end

      def self.gpg_options(options = {})
        OPTIONS.merge(options).map { |k, v| !v ? nil : "--#{k.to_s.gsub('_', '-')} #{v == true ? '' : v.to_s}".rstrip }.compact
      end

      def self.escapeshellarg(arg)
        return RUBY_PLATFORM =~ /mswin32/ ? "\"#{arg.to_s.gsub('"', '\\"')}\"" : "'#{arg.to_s.gsub("'", "\\'")}'"
      end
  end
end
