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
        it "returns a pointer to the computed digest" do
          bitcache_md5("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_md5(data, size, buffer)" do
        it "returns a pointer to the given buffer" do
          # TODO
        end
      end
    end

    # Digest API: SHA-1
    context "SHA-1" do
      # byte* bitcache_sha1(const byte* data, const size_t size, byte* buffer);
      describe "bitcache_sha1(data, size, NULL)" do
        it "returns a pointer to the computed digest" do
          bitcache_sha1("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_sha1(data, size, buffer)" do
        it "returns a pointer to the given buffer" do
          # TODO
        end
      end
    end

    # Digest API: SHA-2
    context "SHA-2" do
      # byte* bitcache_sha256(const byte* data, const size_t size, byte* buffer);
      describe "bitcache_sha256(data, size, NULL)" do
        it "returns a pointer to the computed digest" do
          bitcache_sha256("foobar", 6, nil).should be_an FFI::Pointer
        end
      end

      describe "bitcache_sha256(data, size, buffer)" do
        it "returns a pointer to the given buffer" do
          # TODO
        end
      end
    end
  end

  ##########################################################################
  # IDENTIFIER API

  context "Identifier API" do
    before :all do
      # TODO
    end

    # Identifier API: Allocators
    context "Allocators" do
      describe "bitcache_id_alloc(type)" do
        it "raises a TypeError unless the type is an Integer" do
          lambda { bitcache_id_alloc(nil).should be_an FFI::Pointer }.should raise_error TypeError
        end

        it "returns a pointer to a newly-allocated identifier" do
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
        it "returns a pointer to a newly-instantiated identifier" do
          id = bitcache_id_new(BITCACHE_SHA1, nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_md5(digest)" do
        it "returns a pointer to a newly-instantiated MD5 identifier" do
          id = bitcache_id_new_md5(nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_sha1(digest)" do
        it "returns a pointer to a newly-instantiated SHA-1 identifier" do
          id = bitcache_id_new_sha1(nil)
          id.should be_an FFI::Pointer
          id.should_not eql NULL
        end
      end

      describe "bitcache_id_new_sha256(digest)" do
        it "returns a pointer to a newly-instantiated SHA-256 identifier" do
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
        it "returns a pointer to a newly-instantiated identifier" do
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
        it "returns a pointer to a newly-instantiated identifier" do
          examples.each do |type, base64|
            id = bitcache_id_new_from_base64_string(base64)
            #bitcache_id_get_type(id).should eql type # FIXME
            #bitcache_id_to_base64_string(id, nil).should eql base64 # TODO
          end
        end
      end

      describe "bitcache_id_copy(id)" do
        it "returns a pointer to a newly-allocated identifier" do
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
          bitcache_id_clear(bitcache_id_new_sha1(nil)).should equal nil
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
          bitcache_id_fill(bitcache_id_new_sha1(nil), 0xff).should equal nil
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
        it "returns a pointer to the digest of the identifier" do
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
    end

    # Identifier API: Predicates
    context "Predicates" do
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
        it "returns a pointer" do
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
  # FILTER API

  context "Filter API" do
    before :all do end

    # Filter API: Allocators
    context "Allocators" do
    end

    # Filter API: Constructors
    context "Constructors" do
    end

    # Filter API: Mutators
    context "Mutators" do
    end

    # Filter API: Accessors
    context "Accessors" do
    end

    # Filter API: Predicates
    context "Predicates" do
    end
  end

  ##########################################################################
  # LIST API

  context "List API" do
    before :all do
      # TODO
    end

    # List API: Allocators
    context "Allocators" do
      describe "bitcache_list_element_alloc()" do
        # TODO
      end

      describe "bitcache_list_element_free(element)" do
        # TODO
      end

      describe "bitcache_list_alloc()" do
        # TODO
      end

      describe "bitcache_list_free(list)" do
        # TODO
      end
    end

    # List API: Constructors
    context "Constructors" do
      describe "bitcache_list_element_new(first, rest)" do
        # TODO
      end

      describe "bitcache_list_element_copy(element)" do
        # TODO
      end

      describe "bitcache_list_new(head)" do
        # TODO
      end

      describe "bitcache_list_copy(list)" do
        # TODO
      end
    end

    # List API: Mutators
    context "Mutators" do
      describe "bitcache_list_element_init(element, first, rest)" do
        # TODO
      end

      describe "bitcache_list_init(list, head)" do
        # TODO
      end

      describe "bitcache_list_clear(list)" do
        # TODO
      end

      describe "bitcache_list_prepend(list, id)" do
        # TODO
      end

      describe "bitcache_list_append(list, id)" do
        # TODO
      end

      describe "bitcache_list_insert(list, id)" do
        # TODO
      end

      describe "bitcache_list_insert_at(list, position, id)" do
        # TODO
      end

      describe "bitcache_list_insert_before(list, next, id)" do
        # TODO
      end

      describe "bitcache_list_insert_after(list, prev, id)" do
        # TODO
      end

      describe "bitcache_list_remove(list, id)" do
        # TODO
      end

      describe "bitcache_list_remove_all(list, id)" do
        # TODO
      end

      describe "bitcache_list_remove_at(list, position)" do
        # TODO
      end

      describe "bitcache_list_reverse(list)" do
        # TODO
      end

      describe "bitcache_list_concat(list1, list2)" do
        # TODO
      end
    end

    # List API: Accessors
    context "Accessors" do
      describe "bitcache_list_get_hash(list)" do
        # TODO
      end

      describe "bitcache_list_get_length(list)" do
        # TODO
      end

      describe "bitcache_list_get_count(list, id)" do
        # TODO
      end

      describe "bitcache_list_get_position(list, id)" do
        # TODO
      end

      describe "bitcache_list_get_rest(list)" do
        # TODO
      end

      describe "bitcache_list_get_first(list)" do
        # TODO
      end

      describe "bitcache_list_get_last(list)" do
        # TODO
      end

      describe "bitcache_list_get_nth(list, position)" do
        # TODO
      end
    end

    # List API: Predicates
    context "Predicates" do
      describe "bitcache_list_is_equal(list1, list2)" do
      end

      describe "bitcache_list_is_empty(list)" do
        # TODO
      end
    end

    # List API: Iterators
    context "Iterators" do
      describe "bitcache_list_foreach(list, func, user_data)" do
        # TODO
      end
    end

    # List API: Converters
    context "Converters" do
      describe "bitcache_list_to_set(list)" do
        it "returns a pointer to a set" do
          # TODO
        end
      end
    end
  end

  ##########################################################################
  # SET API

  context "Set API" do
    before :all do
      @id1 = bitcache_id_new_sha1(nil)
      bitcache_id_fill(@id1, 0xaa)
      @id2 = bitcache_id_new_sha1(nil)
      bitcache_id_fill(@id2, 0xbb)
      @id3 = bitcache_id_new_sha1(nil)
      bitcache_id_fill(@id3, 0xcc)
    end

    # Set API: Allocators
    context "Allocators" do
      describe "bitcache_set_alloc()" do
        it "returns a pointer to a newly-allocated set" do
          set = bitcache_set_alloc()
          set.should be_an FFI::Pointer
          set.should_not eql NULL
        end
      end

      describe "bitcache_set_free(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_free(0) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_free(bitcache_set_alloc()).should equal nil
        end

        it "releases the memory allocated to the set" do
          # TODO
        end
      end
    end

    # Set API: Constructors
    context "Constructors" do
      describe "bitcache_set_new()" do
        it "returns a pointer to a newly-instantiated set" do
          set = bitcache_set_new()
          set.should be_an FFI::Pointer
          set.should_not eql NULL
        end
      end

      describe "bitcache_set_new_union(set1, set2)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_new_union(0, 1) }.should raise_error ArgumentError
        end

        it "returns a pointer to a newly-instantiated set" do
          set = bitcache_set_new_union(bitcache_set_new(), bitcache_set_new())
          set.should be_an FFI::Pointer
          set.should_not eql NULL
        end

        it "instantiates the new set from the set union between set1 and set2" do
          set1 = bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set1, @id2)

          set2 = bitcache_set_new()
          bitcache_set_insert(set2, @id2)
          bitcache_set_insert(set2, @id3)

          set3 = bitcache_set_new_union(set1, set2)
          bitcache_set_get_size(set3).should eql 3
          bitcache_set_has_element(set3, @id1).should eql true
          bitcache_set_has_element(set3, @id2).should eql true
          bitcache_set_has_element(set3, @id3).should eql true
        end
      end

      describe "bitcache_set_new_intersection(set1, set2)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_new_intersection(0, 1) }.should raise_error ArgumentError
        end

        it "returns a pointer to a newly-instantiated set" do
          set = bitcache_set_new_intersection(bitcache_set_new(), bitcache_set_new())
          set.should be_an FFI::Pointer
          set.should_not eql NULL
        end

        it "instantiates the new set from the set intersection between set1 and set2" do
          set1 = bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set1, @id2)

          set2 = bitcache_set_new()
          bitcache_set_insert(set2, @id2)
          bitcache_set_insert(set2, @id3)

          set3 = bitcache_set_new_intersection(set1, set2)
          bitcache_set_get_size(set3).should eql 1
          bitcache_set_has_element(set3, @id1).should eql false
          bitcache_set_has_element(set3, @id2).should eql true
          bitcache_set_has_element(set3, @id3).should eql false
        end
      end

      describe "bitcache_set_new_difference(set1, set2)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_new_difference(0, 1) }.should raise_error ArgumentError
        end

        it "returns a pointer to a newly-instantiated set" do
          set = bitcache_set_new_difference(bitcache_set_new(), bitcache_set_new())
          set.should be_an FFI::Pointer
          set.should_not eql NULL
        end

        it "instantiates the new set from the set difference between set1 and set2" do
          set1 = bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set1, @id2)

          set2 = bitcache_set_new()
          bitcache_set_insert(set2, @id2)
          bitcache_set_insert(set2, @id3)

          set3 = bitcache_set_new_difference(set1, set2)
          bitcache_set_get_size(set3).should eql 2
          bitcache_set_has_element(set3, @id1).should eql true
          bitcache_set_has_element(set3, @id2).should eql false
          bitcache_set_has_element(set3, @id3).should eql true
        end
      end

      describe "bitcache_set_copy(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_copy(0) }.should raise_error ArgumentError
        end

        it "returns a pointer to a newly-allocated set" do
          set1 = bitcache_set_new()
          set2 = bitcache_set_copy(set1)
          set2.should be_an FFI::Pointer
          set2.should_not eql NULL
          set2.should_not eql set1
        end

        it "returns a pointer to a set equal to the given set" do
          set1 = bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set1, @id2)
          set2 = bitcache_set_copy(set1)
          bitcache_set_is_equal(set1, set2).should eql true
        end
      end
    end

    # Set API: Mutators
    context "Mutators" do
      describe "bitcache_set_init(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_init(0) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_init(bitcache_set_alloc()).should equal nil
        end

        it "initializes the given newly-allocated set" do
          set = bitcache_set_alloc()
          # TODO: check that set->map is NULL
          bitcache_set_init(set)
          # TODO: check that set->map is no longer NULL
        end
      end

      describe "bitcache_set_clear(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_clear(0) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_clear(bitcache_set_new()).should equal nil
        end

        it "removes all elements from the set" do
          set = bitcache_set_new()
          bitcache_set_get_size(set).should eql 0
          bitcache_set_insert(set, @id1)
          bitcache_set_get_size(set).should eql 1
          bitcache_set_clear(set)
          bitcache_set_get_size(set).should eql 0
        end
      end

      describe "bitcache_set_insert(set, id)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_insert(0, @id1) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_insert(bitcache_set_new(), @id1).should equal nil
        end

        it "inserts the given identifier into the set" do
          set = bitcache_set_new()
          bitcache_set_get_size(set).should eql 0
          bitcache_set_insert(set, @id1)
          bitcache_set_get_size(set).should eql 1
        end
      end

      describe "bitcache_set_remove(set, id)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_remove(0, @id1) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_remove(bitcache_set_new(), @id1).should equal nil
        end

        it "removes the given identifier from the set" do
          set = bitcache_set_new()
          bitcache_set_get_size(set).should eql 0
          bitcache_set_insert(set, @id1)
          bitcache_set_get_size(set).should eql 1
          bitcache_set_remove(set, @id1)
          bitcache_set_get_size(set).should eql 0
        end
      end

      describe "bitcache_set_replace(set, id1, id2)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_replace(0, @id1, @id2) }.should raise_error ArgumentError
        end

        it "returns void" do
          bitcache_set_replace(bitcache_set_new(), @id1, @id2).should equal nil
        end

        it "removes the first identifier from the set" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_has_element(set, @id1).should eql true
          bitcache_set_replace(set, @id1, @id2)
          bitcache_set_has_element(set, @id1).should eql false
        end

        it "inserts the second identifier into the set" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_has_element(set, @id2).should eql false
          bitcache_set_replace(set, @id1, @id2)
          bitcache_set_has_element(set, @id2).should eql true
        end
      end

      describe "bitcache_set_merge(set1, set2, op)" do
        it "raises an ArgumentError if the two first arguments are not pointers" do
          lambda { bitcache_set_merge(0, 0, BITCACHE_OP_OR) }.should raise_error ArgumentError
        end

        it "returns void" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_merge(set1, set2, BITCACHE_OP_OR).should equal nil
        end

        # TODO
      end
    end

    # Set API: Accessors
    context "Accessors" do
      describe "bitcache_set_get_hash(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_get_hash(0) }.should raise_error ArgumentError
        end

        it "returns an Integer" do
          bitcache_set_get_hash(bitcache_set_new()).should be_an Integer
        end

        it "returns a hash code based on the pointer address of the set" do
          set = bitcache_set_new()
          ("0x%x" % set.to_i).should include ("%x" % bitcache_set_get_hash(set))
        end

        it "returns a differing hash code for different sets" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_get_hash(set1).should_not eql bitcache_set_get_hash(set2)
        end
      end

      describe "bitcache_set_get_size(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_get_size(0) }.should raise_error ArgumentError
        end

        it "returns an Integer" do
          bitcache_set_get_size(bitcache_set_new()).should be_an Integer
        end

        it "returns the cardinality of the set" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_insert(set, @id2)
          bitcache_set_get_size(set).should eql 2
        end

        it "returns zero for the empty set" do
          set = bitcache_set_new()
          bitcache_set_get_size(set).should be_zero
        end

        it "returns the correct cardinality even after inserts and removes" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_insert(set, @id2)
          bitcache_set_remove(set, @id1)
          bitcache_set_get_size(set).should eql 1
        end
      end

      describe "bitcache_set_get_count(set, id)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_get_count(0, @id1) }.should raise_error ArgumentError
          lambda { bitcache_set_get_count(bitcache_set_new(), 0) }.should raise_error ArgumentError
        end

        it "returns an Integer" do
          bitcache_set_get_count(bitcache_set_new(), @id1).should be_an Integer
        end

        it "returns zero for the empty set" do
          bitcache_set_get_count(bitcache_set_new(), @id1).should be_zero
        end

        it "returns zero if the set does not contain the given identifier" do
          set = bitcache_set_new()
          bitcache_set_get_count(set, @id1).should be_zero
        end

        it "returns one if the set contains the given identifier" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_get_count(set, @id1).should eql 1
        end
      end
    end

    # Set API: Predicates
    context "Predicates" do
      describe "bitcache_set_is_equal(set1, set2)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_is_equal(0, 1) }.should raise_error ArgumentError
        end

        it "returns a Boolean" do
          set1 = set2 = bitcache_set_new()
          bitcache_set_is_equal(set1, set2).should be_a_boolean
        end

        it "returns TRUE if set1 and set2 are the same pointer" do
          set1 = set2 = bitcache_set_new()
          bitcache_set_is_equal(set1, set2).should eql true
        end

        it "returns TRUE if set1 and set2 both point to empty sets" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_is_equal(set1, set2).should eql true
        end

        it "returns FALSE if set1 and set2 are pointers to sets of differing cardinality" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_is_equal(set1, set2).should eql false
        end

        it "returns TRUE if set1 and set2 are pointers to equal sets" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set2, @id1)
          bitcache_set_is_equal(set1, set2).should eql true
        end

        it "returns FALSE if set1 and set2 are pointers to differing sets" do
          set1, set2 = bitcache_set_new(), bitcache_set_new()
          bitcache_set_insert(set1, @id1)
          bitcache_set_insert(set2, @id2)
          bitcache_set_is_equal(set1, set2).should eql false
        end
      end

      describe "bitcache_set_is_empty(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_is_empty(0) }.should raise_error ArgumentError
        end

        it "returns a Boolean" do
          bitcache_set_is_empty(bitcache_set_new()).should be_a_boolean
        end

        it "returns TRUE if the set is empty" do
          set = bitcache_set_new()
          bitcache_set_is_empty(set).should eql true
        end

        it "returns FALSE if the set is not empty" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_is_empty(set).should eql false
        end
      end

      describe "bitcache_set_has_element(set, id)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_has_element(0, @id1) }.should raise_error ArgumentError
          lambda { bitcache_set_has_element(bitcache_set_new(), 0) }.should raise_error ArgumentError
        end

        it "returns a Boolean" do
          bitcache_set_has_element(bitcache_set_new(), @id1).should be_a_boolean
        end

        it "returns TRUE if the set contains the given identifier" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_has_element(set, @id1).should eql true
        end

        it "returns FALSE if the set does not contain the given identifier" do
          set = bitcache_set_new()
          bitcache_set_has_element(set, @id1).should eql false
        end
      end
    end

    # Set API: Iterators
    context "Iterators" do
      describe "bitcache_set_foreach(set, func, user_data)" do
        it "raises an ArgumentError if the arguments are not pointers" do
          lambda { bitcache_set_foreach(0, 1, 2) }.should raise_error ArgumentError
        end

        # TODO

        it "returns void" do
          # TODO
        end
      end
    end

    # Set API: Converters
    context "Converters" do
      describe "bitcache_set_to_list(set)" do
        it "raises an ArgumentError if the argument is not a pointer" do
          lambda { bitcache_set_to_list(0) }.should raise_error ArgumentError
        end

        it "returns a valid pointer to a list" do
          list = bitcache_set_to_list(bitcache_set_new())
          list.should be_an FFI::Pointer
          list.should_not eql NULL
        end

        it "converts the set into a list of the same cardinality" do
          set = bitcache_set_new()

          bitcache_set_insert(set, @id1)
          list = bitcache_set_to_list(set)
          bitcache_list_get_length(list).should eql 1

          bitcache_set_insert(set, @id2)
          list = bitcache_set_to_list(set)
          bitcache_list_get_length(list).should eql 2
        end

        it "converts the set into a list with the same elements" do
          set = bitcache_set_new()
          bitcache_set_insert(set, @id1)
          bitcache_set_insert(set, @id2)
          bitcache_set_insert(set, @id3)

          list = bitcache_set_to_list(set)
          bitcache_list_get_count(list, @id1).should eql 1
          bitcache_list_get_count(list, @id2).should eql 1
          bitcache_list_get_count(list, @id3).should eql 1
        end
      end
    end
  end

  ##########################################################################

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
