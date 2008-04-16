module Bitcache
  @@sources = {}

  def self.load_config!
    @@sources = Bitcache::Config.load_repos
    class <<@@sources
      def [](key)
        fetch(key ? key.to_sym : nil, nil)
      end
    end
  end

  def self.sources
    @@sources
  end

  def self.source?(name)
    @@sources.has_key?(name.to_sym)
  end

  def self.default
    !sources.empty? ? sources.values.first : nil
  end

  def self.keys
    keys = {}
    sources.each_value do |src|
      src.each_key { |key| keys[key] = nil }
    end
    keys.keys
  end

  def self.include?(key)
    sources.values.any? { |src| src.include?(key) }
  end

  def self.[](key)
    key = key.to_s
    sources.each_value do |src|
      return src[key] if src.include?(key)
    end
  end

  def self.<<(repo)
    # TODO
  end

end
