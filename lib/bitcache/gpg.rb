module Bitcache
  module GPG
    class EncryptionError < RuntimeError ; end

    OPTIONS = {
      :cipher_algo    => :aes256,
      :digest_algo    => :sha1,
      :compress_algo  => :bzip2,
      :passphrase_fd  => 0,
      :output         => '-',
      :quiet          => true,
      :batch          => true,
      :no_mdc_warning => true, # for decryption
    }

    def self.encrypt(file, password)
      gpg('-c', escapeshellarg(file)) { |io| io.puts password; io.close_write; io.read }
    end

    def self.decrypt(file, password)
      gpg('-d', escapeshellarg(file)) { |io| io.puts password; io.close_write; io.read }
    end

    protected

      def self.gpg(*args, &block)
        options = OPTIONS.map { |k, v| !v ? nil : "--#{k.to_s.gsub('_', '-')} #{v == true ? '' : v.to_s}".rstrip }.compact
        result = IO.popen('gpg ' + (options + args).join(' ') + ' 2>&1', 'r+', &block)
        raise EncryptionError, result.chomp if $?.exitstatus != 0
        result
      end

      def self.escapeshellarg(arg)
        return RUBY_PLATFORM =~ /mswin32/ ? "\"#{arg.gsub('"', '\\"')}\"" : "'#{arg.gsub("'", "\\'")}'"
      end
  end
end
