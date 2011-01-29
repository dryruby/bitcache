module Bitcache::TokyoCabinet
  ##
  # Tokyo Cabinet repository implementation.
  #
  # @see http://1978th.net/tokyocabinet/spex-en.html
  # @see http://1978th.net/tokyocabinet/rubydoc/
  class Repository # < Bitcache::Repository
    include TokyoCabinet

    FILE_EXTENSION = '.tcb'

    ##
    # @param  [#to_s] path
    # @param  [Symbol] mode
    # @yield  [repo]
    # @yieldparam  [Repository] repo
    # @yieldreturn [void]
    # @return [Repository]
    def self.open(path, mode = :read, &block)
      repo = self.new(path)
      repo.open(mode) do
        block.call(repo)
      end
    end

    ##
    # @param  [#to_s] path
    def initialize(path)
      @path, @db = path.to_s, BDB.new
    end

    ##
    # @return [Boolean] `true` or `false`
    def open?
      @open || false
    end

    ##
    # @param  [Symbol] mode
    # @yield  [db]
    # @yieldparam  [BDB] db
    # @yieldreturn [void]
    # @return [void]
    def open(mode = :read, &block)
      if @open
        block_given? ? block.call(@db) : self
      else
        @mode = case mode
          when 'r', :read  then BDB::OREADER
          when 'w', :write then BDB::OWRITER | BDB::OCREAT
          else raise ArgumentError, "expected :read/:write or 'r'/'w', but got #{mode.inspect}"
        end

        @db.open(@path, mode) or raise_error!
        @open = true

        result = self
        if block_given?
          begin
            result = block.call(@db)
          ensure
            @db.close or raise_error!
            @open = false
            @mode = nil
          end
        end
        result
      end
    end

    ##
    # @return [Boolean] `true` or `false`
    def closed?
      !(open?)
    end

    ##
    # @return [void] `self`
    def close
      @db.close or raise_error! if @open
      @open = false
      @mode = nil
      return self
    end

    ##
    # @return [Integer]
    def size
      open(:read) do |db|
        db.fsiz()
      end
    end
    alias_method :bytesize, :size

    ##
    # @return [Integer]
    def count
      open(:read) do |db|
        db.rnum()
      end
    end

    ##
    # @param  [Identifier] id
    # @return [Boolean] `true` or `false`
    def has_identifier?(id)
      check_id!(id)
      open(:read) do |db|
        !(db.vnum(id.to_str).zero?)
      end
    end

    ##
    # @yield  [id]
    # @yieldparam  [Identifier] id
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    def each_identifier(&block)
      if block_given?
        open(:read) do |db|
          cursor = BDBCUR.new(db)
          cursor.first()
          while key = cursor.key()
            block.call(Bitcache::Identifier.new(key))
            cursor.next()
          end
        end
      end
      enum_for(:each_identifier)
    end

    ##
    # @param  [Identifier] id
    # @return [String]
    def [](id)
      check_id!(id)
      open(:read) do |db|
        db.get(id.to_str)
      end
    end

    ##
    # @param  [Identifier] id
    # @param  [String] data
    # @return [void]
    def []=(id, data)
      check_id!(id)
      open(:write) do |db|
        db.putkeep(id.to_str, data) or (db.ecode != BDB::EKEEP && raise_error!)
      end
    end

    ##
    # @param  [String] data
    # @return [void] `self`
    def <<(data)
      self[Bitcache.identify(data)] = data
      return self
    end

    ##
    # @return [void] `self`
    def clear
      open(:write) do |db|
        db.vanish()
      end
      return self
    end

  protected

    ##
    # @private
    # @return [void]
    def sync
      @db.sync()
    end

    ##
    # @private
    # @return [void]
    def check_id!(id)
      raise ArgumentError, "expected Identifier, but got #{id.inspect}" unless id.is_a?(Bitcache::Identifier)
    end

    ##
    # @private
    # @return [void]
    def raise_error!
      raise @db.errmsg(@db.ecode())
    end
  end # Repository
end # Bitcache::TokyoCabinet
