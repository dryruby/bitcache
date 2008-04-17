require 'open4'

module Bitcache
  module GPG
    class Error < RuntimeError ; end

    OPTIONS = {
      :cipher_algo    => :aes256,
      :digest_algo    => :sha1,
      :compress_algo  => :bzip2,
      :output         => '-',
      :quiet          => true,
      :batch          => true,
      :no_mdc_warning => true, # for decryption
    }

    def self.encrypt(data, passphrase, options = {}, &block)
      output = gpg('-c', options.merge(:passphrase => passphrase)) do |stdin, stdout, stderr|
        #expect statout, /BEGIN_ENCRYPTION/
        stdin.write data
        stdin.close_write
        #expect statout, /END_ENCRYPTION/
      end
      block_given? ? block.call(output) : output.read
    end

    def self.decrypt(data, passphrase, options = {}, &block)
      output = gpg('-d', options.merge(:passphrase => passphrase)) do |stdin, stdout, stderr|
        #expect statout, /BEGIN_DECRYPTION/
        stdin.write data
        stdin.close_write
        #expect statout, /END_DECRYPTION/
      end
      block_given? ? block.call(output) : output.read
    end

    protected

      def self.expect(io, marker)
        io.each do |status|
          puts status if $DEBUG
          break if status =~ marker
        end
      end

      def self.gpg_options(options = {})
        OPTIONS.merge(options).map { |k, v| !v ? nil : "--#{k.to_s.gsub('_', '-')} #{v == true ? '' : v.to_s}".rstrip }.compact
      end

      def self.gpg(arg, options = {}, &block)
        #statout, statin = IO.pipe
        #options[:status_fd] = statin.fileno

        passphrase = options.delete(:passphrase)
        passout, passin = IO.pipe
        options[:passphrase_fd] = passout.fileno

        cmd = 'gpg ' + (gpg_options(options) + [arg]).flatten.join(' ')
        puts cmd if $DEBUG

        pid, stdin, stdout, stderr = Open4.popen4(cmd)
        passin.puts passphrase
        passin.close_write

        block.call(stdin, stdout, stderr)
        pid, status = Process.waitpid2(pid)

        raise Error, stderr.read.chomp if status.exitstatus != 0
        stdout
      end

      def self.escapeshellarg(arg)
        return RUBY_PLATFORM =~ /mswin32/ ? "\"#{arg.gsub('"', '\\"')}\"" : "'#{arg.gsub("'", "\\'")}'"
      end
  end
end
