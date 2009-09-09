package org.bitcache;

public class Stream {
  public Identifier id;
  public byte[] data;

  public Stream(Identifier id) {
    this(id, (byte[])null);
  }

  public Stream(String data) {
    this(null, data.getBytes());
  }

  public Stream(byte[] data) {
    this(null, data);
  }

  public Stream(Identifier id, String data) {
    this(id, data.getBytes());
  }

  public Stream(Identifier id, byte[] data) {
    this.id   = id;
    this.data = data;
  }

  public String toString() {
    return new String(this.data);
  }

  public Identifier id() {
    if (this.id == null) {
      this.id = Identifier.forBytes(this.data);
    }
    return this.id;
  }

  public byte[] data() {
    return this.data;
  }

  public int size() {
    return this.data.length;
  }

  public String type() {
    return "application/octet-stream";
  }

  public boolean isCompressed() {
    return false;
  }

  public boolean isEncrypted() {
    return false;
  }

  public int hashCode() {
    return toString().hashCode();
  }

  public boolean equals(Object other) {
    return (other instanceof Stream) && equals((Stream)other);
  }

  public boolean equals(Stream other) {
    return toString().equals(other.toString());
  }
}
