require File.join(File.dirname(__FILE__), 'spec_helper')
include Bitcache::FFI

describe Bitcache::FFI do
  context "Constants" do
    # const char* const bitcache_version_string;
    describe "bitcache_version_string" do
      it "returns a String" do
        Bitcache::FFI.bitcache_version_string.should be_a String
      end

      it "returns the version string '#{Bitcache::VERSION}'" do
        Bitcache::FFI.bitcache_version_string.should eql Bitcache::VERSION.to_s
      end
    end
  end

  ##########################################################################
  # DIGEST API

  context "Digest API" do

    # Digest API: MD5
    context "MD5" do
      # byte* bitcache_md5(const byte* data, const size_t size, byte* buffer);
      describe "bitcache_md5(data, size, NULL)" do
        it "returns a Pointer to the computed digest" do
          bitcache_md5("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_md5(data, size, buffer)" do
        it "returns a Pointer to the given buffer" do
          # TODO
        end
      end
    end

    # Digest API: SHA-1
    context "SHA-1" do
      # byte* bitcache_sha1(const byte* data, const size_t size, byte* buffer);
      describe "bitcache_sha1(data, size, NULL)" do
        it "returns a Pointer to the computed digest" do
          bitcache_sha1("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_sha1(data, size, buffer)" do
        it "returns a Pointer to the given buffer" do
          # TODO
        end
      end
    end

    # Digest API: SHA-2
    context "SHA-2" do
      # byte* bitcache_sha256(const byte* data, const size_t size, byte* buffer);
      describe "bitcache_sha256(data, size, NULL)" do
        it "returns a Pointer to the computed digest" do
          bitcache_sha256("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_sha256(data, size, buffer)" do
        it "returns a Pointer to the given buffer" do
          # TODO
        end
      end
    end
  end

  ##########################################################################
  # IDENTIFIER API

  context "Identifier API" do

    # Identifier API: Allocators
    context "Allocators" do
      describe "bitcache_id_alloc(type)" do
        it "raises a TypeError unless the type is an Integer" do
          lambda { bitcache_id_alloc(nil).should be_an FFI::Pointer }.should raise_error TypeError
        end

        it "returns a Pointer to a newly-allocated identifier" do
          id = bitcache_id_alloc(BITCACHE_SHA1)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_free(id)" do
        it "returns void" do
          bitcache_id_free(bitcache_id_alloc(BITCACHE_SHA1)).should equal nil
        end

        it "releases the memory allocated to the identifier" do
          id = bitcache_id_alloc(BITCACHE_SHA1)
          # TODO
        end
      end
    end

    # Identifier API: Constructors
    context "Constructors" do
      describe "bitcache_id_new(type, digest)" do
        it "returns a Pointer to a newly-instantiated identifier" do
          id = bitcache_id_new(BITCACHE_SHA1, nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_md5(digest)" do
        it "returns a Pointer to a newly-instantiated MD5 identifier" do
          id = bitcache_id_new_md5(nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_sha1(digest)" do
        it "returns a Pointer to a newly-instantiated SHA-1 identifier" do
          id = bitcache_id_new_sha1(nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_sha256(digest)" do
        it "returns a Pointer to a newly-instantiated SHA-256 identifier" do
          id = bitcache_id_new_sha256(nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_from_hex_string(string)" do
        examples = {
          BITCACHE_MD5  => '3858f62230ac3c915f300c664312c63f',         # HEX(MD5('foobar'))
          BITCACHE_SHA1 => '8843d7f92416211de9ebb963ff4ce28125932878', # HEX(SHA-1('foobar'))
        }
        it "returns a Pointer to a newly-instantiated identifier" do
          examples.each do |type, hex|
            id = bitcache_id_new_from_hex_string(hex)
            bitcache_id_get_type(id).should eql type
            #bitcache_id_to_hex_string(id, nil).should eql hex # TODO
          end
        end
      end

      describe "bitcache_id_new_from_base64_string(string)" do
        examples = {
          BITCACHE_MD5  => '',         # BASE64(MD5('foobar'))
          BITCACHE_SHA1 => '',         # BASE64(SHA-1('foobar'))
        }
        it "returns a Pointer to a newly-instantiated identifier" do
          examples.each do |type, base64|
            id = bitcache_id_new_from_base64_string(base64)
            #bitcache_id_get_type(id).should eql type # FIXME
            #bitcache_id_to_base64_string(id, nil).should eql base64 # TODO
          end
        end
      end

      describe "bitcache_id_copy(id)" do
        it "returns a Pointer to a newly-allocated identifier" do
          id1 = bitcache_id_new_sha1(nil)
          id2 = bitcache_id_copy(id1)
          id2.should be_an FFI::Pointer
          id2.should_not eql NULL
          id2.should_not eql id1
        end
      end
    end

    # Identifier API: Mutators
    context "Mutators" do
      describe "bitcache_id_init(id, type, data)" do
        it "returns void" do
          bitcache_id_init(bitcache_id_alloc(BITCACHE_SHA1), BITCACHE_SHA1, nil).should equal nil
        end

        it "initializes the given newly-allocated identifier" do
          id = bitcache_id_alloc(BITCACHE_SHA256)
          bitcache_id_get_type(id).should eql BITCACHE_SHA256
          bitcache_id_init(id, BITCACHE_SHA1, nil)
          bitcache_id_get_type(id).should eql BITCACHE_SHA1
        end
      end

      describe "bitcache_id_clear(id)" do
        it "returns void" do
          bitcache_id_clear(bitcache_id_alloc(BITCACHE_SHA1)).should equal nil
        end

        it "sets the digest of the identifier to all zeroes" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id, 0xff)
          bitcache_id_clear(id)
          bitcache_id_to_hex_string(id, nil).should eql '00' * BITCACHE_SHA1_SIZE
        end
      end

      describe "bitcache_id_fill(id, value)" do
        it "returns void" do
          bitcache_id_fill(bitcache_id_alloc(BITCACHE_SHA1), 0xff).should equal nil
        end

        it "fills the digest of the identifier with the given byte value" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id, 0xab)
          bitcache_id_to_hex_string(id, nil).should == "ab" * BITCACHE_SHA1_SIZE
        end
      end
    end

    # Identifier API: Accessors
    context "Accessors" do
      describe "bitcache_id_get_type(id)" do
        it "returns an Integer" do
          bitcache_id_get_type(bitcache_id_new_sha1(nil)).should be_an Integer
        end

        it "returns the digest type of the identifier" do
          bitcache_id_get_type(bitcache_id_new_md5(nil)).should eql BITCACHE_MD5
          bitcache_id_get_type(bitcache_id_new_sha1(nil)).should eql BITCACHE_SHA1
          bitcache_id_get_type(bitcache_id_new_sha256(nil)).should eql BITCACHE_SHA256
        end
      end

      describe "bitcache_id_get_digest(id)" do
        it "returns a Pointer to the digest of the identifier" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_get_digest(id).should be_an FFI::Pointer
          bitcache_id_get_digest(id).should == id + 4 # sizeof(bitcache_type_id)
        end
      end

      describe "bitcache_id_get_digest_size(id)" do
        it "returns an Integer" do
          bitcache_id_get_digest_size(bitcache_id_new_sha1(nil)).should be_an Integer
        end

        it "returns the digest size of the identifier" do
          bitcache_id_get_digest_size(bitcache_id_new_md5(nil)).should eql BITCACHE_MD5_SIZE
          bitcache_id_get_digest_size(bitcache_id_new_sha1(nil)).should eql BITCACHE_SHA1_SIZE
          bitcache_id_get_digest_size(bitcache_id_new_sha256(nil)).should eql BITCACHE_SHA256_SIZE
        end
      end

      describe "bitcache_id_get_hash(id)" do
        it "returns an Integer" do
          bitcache_id_get_hash(bitcache_id_new_sha1(nil)).should be_an Integer
        end

        it "returns a hash code based on the digest of the identifier" do
          id1 = bitcache_id_new_sha1(nil)
          bitcache_id_get_hash(id1).should eql 0

          id2 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id2, 0xff)
          bitcache_id_get_hash(id2).should eql 0xffffffff
        end
      end
    end

    # Identifier API: Predicates
    context "Predicates" do
      describe "bitcache_id_is_zero(id)" do
        it "returns a Boolean" do
          bitcache_id_is_zero(bitcache_id_new_sha1(nil)).should be_a_boolean
        end

        it "returns TRUE if the digest of the identifier is all zeroes" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id, 0x00)
          bitcache_id_is_zero(id).should eql true
        end

        it "returns FALSE if the digest of the identifier is not all zeroes" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id, 0xff)
          bitcache_id_is_zero(id).should eql false
        end
      end

      describe "bitcache_id_is_equal(id1, id2)" do
        it "returns a Boolean" do
          id1 = id2 = bitcache_id_new_sha1(nil)
          bitcache_id_is_equal(id1, id2).should be_a_boolean
        end

        it "returns TRUE if id1 and id2 are the same pointer" do
          id1 = id2 = bitcache_id_new_sha1(nil)
          bitcache_id_is_equal(id1, id2).should eql true
        end

        it "returns TRUE if id1 and id2 are pointers to equal identifiers" do
          id1 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id1, 0xab)
          id2 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id2, 0xab)
          bitcache_id_is_equal(id1, id2).should eql true
        end

        it "returns FALSE otherwise" do
          id1 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id1, 0xab)
          id2 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id2, 0xba)
          bitcache_id_is_equal(id1, id2).should eql false
        end
      end
    end

    # Identifier API: Comparators
    context "Comparators" do
      describe "bitcache_id_compare(id1, id2)" do
        it "returns an Integer" do
          id1 = id2 = bitcache_id_new_sha1(nil)
          bitcache_id_compare(id1, id2).should be_an Integer
        end

        it "returns zero if id1 and id2 are the same pointer" do
          id1 = id2 = bitcache_id_new_sha1(nil)
          bitcache_id_compare(id1, id2).should be_zero
        end

        it "returns zero if id1 and id2 are pointers to equal identifiers" do
          id1 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id1, 0xab)
          id2 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id2, 0xab)
          bitcache_id_compare(id1, id2).should be_zero
        end

        it "returns non-zero otherwise" do
          id1 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id1, 0xab)
          id2 = bitcache_id_new_sha1(nil)
          bitcache_id_fill(id2, 0xba)
          bitcache_id_compare(id1, id2).should_not be_zero
        end

        it "returns non-zero if id1 and id2 are of different identifier types" do
          id1 = bitcache_id_new_md5(nil)
          id2 = bitcache_id_new_sha1(nil)
          #bitcache_id_compare(id1, id2).should_not be_zero unless debug? # FIXME: assert
        end
      end
    end

    # Identifier API: Converters
    context "Converters" do
      describe "bitcache_id_to_hex_string(id, NULL)" do
        it "returns a String" do
          bitcache_id_to_hex_string(bitcache_id_new_sha1(nil), nil).should be_a String
        end

        it "returns the lowercase hexadecimal representation of the identifier" do
          id = bitcache_id_new_sha1(nil)
          bitcache_id_to_hex_string(id, nil).should == '00' * BITCACHE_SHA1_SIZE
          # TODO: check for lowercase
        end
      end

      describe "bitcache_id_to_hex_string(id, buffer)" do
        # TODO
      end

      describe "bitcache_id_to_base64_string(id, NULL)" do
        it "returns a String" do
          #bitcache_id_to_base64_string(bitcache_id_new_sha1(nil), nil).should be_a String # FIXME
        end

        it "returns the Base64 representation of the identifier" do
          id = bitcache_id_new_sha1(nil)
          #bitcache_id_to_base64_string(id, nil).should == [bitcache_id_get_digest(id)].pack('m').chomp # FIXME
        end
      end

      describe "bitcache_id_to_base64_string(id, buffer)" do
        # TODO
      end

      describe "bitcache_id_to_mpi(id, NULL)" do
        it "returns a Pointer" do
          bitcache_id_to_mpi(bitcache_id_new_sha1(nil), nil).should be_an FFI::Pointer
        end

        it "returns the multiprecision integer representation of the identifier" do
          id = bitcache_id_new_sha1(nil)
          # TODO
        end
      end

      describe "bitcache_id_to_mpi(id, buffer)" do
        # TODO
      end
    end
  end

  ##########################################################################
  # LIST API

  context "List API" do
    # TODO
  end

  context "Set API" do
    # TODO
  end

  context "Queue API" do
    # TODO
  end

  context "Index API" do
    # TODO
  end

  context "Stream API" do
    # TODO
  end
end
