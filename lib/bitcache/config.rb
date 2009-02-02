require 'yaml'
require 'erb'

module Bitcache

  module Config

    DEFAULT_PATH = '~/.bitrc'

    def self.load_repos(options = {})
      repos = {}
      self.load(options[:config] || DEFAULT_PATH).each do |name, config|
        if config[:enabled] != false
          repos[name.to_sym] = Repository.new(Adapter.new(options.merge(config)), config)
        end
      end
      repos
    end

    def self.load(file)
      file = File.expand_path(file)

      raise "Configuration file #{file} doesn't exist." unless File.exists?(file)
      raise "Configuration file #{file} isn't readable." unless File.readable?(file)

      hash = self.symbolify_keys!(::YAML::load(ERB.new(IO.read(file)).result))
    end

    protected

      # Recursively convert all Hash keys to symbols.
      def self.symbolify_keys!(hash)
        hash.each_key do |key|
          unless key.is_a?(Symbol)
            value = hash[key]
            hash[key.to_sym] = value.is_a?(Hash) ? symbolify_keys!(value) : value
            hash.delete(key)
          end
        end
        hash
      end
  end
end
