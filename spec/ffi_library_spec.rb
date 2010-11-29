require File.join(File.dirname(__FILE__), 'spec_helper')
include Bitcache::FFI

describe Bitcache::FFI do
  context "Constants" do
    describe "bitcache_version_string" do
      it "returns the version string '#{Bitcache::VERSION}'" do
        Bitcache::FFI.bitcache_version_string.should == Bitcache::VERSION.to_s
      end
    end
  end

  context "Digest API" do
    describe "bitcache_md5(data, size, digest)" do
    end

    describe "bitcache_sha1(data, size, digest)" do
    end

    describe "bitcache_sha256(data, size, digest)" do
    end
  end

  context "Identifier API" do
    describe "bitcache_id_alloc(type)" do
    end

    describe "bitcache_id_copy(id)" do
    end

    describe "bitcache_id_new_md5(digest)" do
    end

    describe "bitcache_id_new_sha1(digest)" do
    end

    describe "bitcache_id_new_sha256(digest)" do
    end

    describe "bitcache_id_new(type, digest)" do
    end

    describe "bitcache_id_new_from_hex_string(string)" do
    end

    describe "bitcache_id_new_from_base64_string(string)" do
    end

    describe "bitcache_id_init(id, type, data)" do
    end

    describe "bitcache_id_free(id)" do
    end

    describe "bitcache_id_clear(id)" do
    end

    describe "bitcache_id_fill(id, value)" do
    end

    describe "bitcache_id_get_type(id)" do
    end

    describe "bitcache_id_get_size(id)" do
    end

    describe "bitcache_id_equal(id1, id2)" do
    end

    describe "bitcache_id_hash(id)" do
    end

    describe "bitcache_id_compare(id1, id2)" do
    end

    describe "bitcache_id_to_hex_string(id, string)" do
    end

    describe "bitcache_id_to_base64_string(id, string)" do
    end

    describe "bitcache_id_to_mpi(id)" do
    end
  end

  context "List API" do
    describe "bitcache_list_alloc()" do
    end

    describe "bitcache_list_copy(list)" do
    end

    describe "bitcache_list_new()" do
    end

    describe "bitcache_list_init(list)" do
    end

    describe "bitcache_list_free(list)" do
    end

    describe "bitcache_list_equal(list1, list2)" do
    end

    describe "bitcache_list_hash(list)" do
    end

    describe "bitcache_list_clear(list)" do
    end

    describe "bitcache_list_append(list, id)" do
    end

    describe "bitcache_list_prepend(list, id)" do
    end

    describe "bitcache_list_insert_at(list, position, id)" do
    end

    describe "bitcache_list_insert_before(list, next, id)" do
    end

    describe "bitcache_list_insert_after(list, prev, id)" do
    end

    describe "bitcache_list_remove_at(list, position)" do
    end

    describe "bitcache_list_remove(list, id)" do
    end

    describe "bitcache_list_remove_all(list, id)" do
    end

    describe "bitcache_list_concat(list1, list2)" do
    end

    describe "bitcache_list_reverse(list)" do
    end

    describe "bitcache_list_is_empty(list)" do
    end

    describe "bitcache_list_length(list)" do
    end

    describe "bitcache_list_count(list, id)" do
    end

    describe "bitcache_list_position(list, element)" do
    end

    describe "bitcache_list_index(list, id)" do
    end

    describe "bitcache_list_find(list, id)" do
    end

    describe "bitcache_list_first(list)" do
    end

    describe "bitcache_list_next(list)" do
    end

    describe "bitcache_list_nth(list, n)" do
    end

    describe "bitcache_list_last(list)" do
    end

    describe "bitcache_list_first_id(list)" do
    end

    describe "bitcache_list_next_id(list)" do
    end

    describe "bitcache_list_nth_id(list, n)" do
    end

    describe "bitcache_list_last_id(list)" do
    end

    describe "bitcache_list_each_id(list, func, user_data)" do
    end
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
