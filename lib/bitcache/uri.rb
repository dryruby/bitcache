require 'uri/generic'

module Bitcache
  class URI < URI::Generic
    include URI::REGEXP

    DEFAULT_PORT = nil
    COMPONENT    = [:scheme, :id].freeze

    def self.build(args)
      tmp = Util::make_components_hash(self, args)
      tmp[:scheme] = 'bitcache'
      tmp[:opaque] = tmp[:id].to_s
      super(tmp)
    end

    attr_accessor :id

    def initialize(*args)
      # HACK: set +self.opaque+ from +self.host+ if needed:
      args[6], args[2] = args[2], nil if args[2]
      super(*args)

      if /([A-Fa-f0-9]+)$/ =~ @opaque
        @id = $1.downcase
      else
        @id = nil
      end
    end

    def to_s
      "#{scheme}://#{id}"
    end
  end

  module ::URI
    @@schemes['BITCACHE'] = Bitcache::URI
  end
end
