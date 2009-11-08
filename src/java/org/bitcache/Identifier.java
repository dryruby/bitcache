package org.bitcache;
import java.io.InputStream;
import java.io.IOException;
import java.io.File;
import java.io.FileInputStream;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.ProviderException;

public class Identifier {
  public static String ALGORITHM = "SHA-1";
  public byte[] id;

  public static String getHexDigest(String text) {
    return Identifier.forString(text).toHexString();
  }

  public static String getHexDigest(byte[] data) {
    return Identifier.forBytes(data).toHexString();
  }

  public static MessageDigest getDigestAlgorithm() {
    return getDigestAlgorithm(ALGORITHM);
  }

  public static MessageDigest getDigestAlgorithm(String algorithm) {
    try {
      return MessageDigest.getInstance(algorithm);
    }
    catch (NoSuchAlgorithmException e) {
      throw new ProviderException(e);
    }
  }

  public static int getDigestLength() {
    return getDigestAlgorithm().getDigestLength();
  }

  public static int getDigestLength(String algorithm) {
    return getDigestAlgorithm(algorithm).getDigestLength();
  }

  public static Identifier forFile(File file) throws IOException {
    return forStream(new FileInputStream(file));
  }

  public static Identifier forStream(InputStream stream) throws IOException {
    return forChannel(Channels.newChannel(stream));
  }

  public static Identifier forChannel(ReadableByteChannel channel) throws IOException {
    MessageDigest digest = getDigestAlgorithm();
    ByteBuffer buffer = ByteBuffer.allocate(4096);
    while (channel.read(buffer) != -1) {
      buffer.flip();
      digest.update(buffer);
      buffer.clear();
    }
    return new Identifier(digest.digest());
  }

  public static Identifier forBuffer(ByteBuffer data) {
    MessageDigest digest = getDigestAlgorithm();
    digest.update(data);
    return new Identifier(digest.digest());
  }

  public static Identifier forString(String text) {
    return forBytes(text.getBytes());
  }

  public static Identifier forBytes(byte[] data) {
    MessageDigest digest = getDigestAlgorithm();
    digest.update(data);
    return new Identifier(digest.digest());
  }

  public Identifier(String id) {
    if (id.length() != getDigestLength() * 2) {
      throw new IllegalArgumentException(
        "expected hex string of length " + (getDigestLength() * 2) + ", but got " + id.length());
    }

    this.id = new byte[id.length() / 2];
    for (int i = 0; i < id.length(); i += 2) {
      this.id[i / 2] = (byte)((Character.digit(id.charAt(i), 16) << 4) +
                               Character.digit(id.charAt(i + 1), 16));
    }
  }

  public Identifier(byte[] id) {
    if (id.length != getDigestLength()) {
      throw new IllegalArgumentException(
        "expected byte[" + getDigestLength() + "], but got byte[" + id.length + "]");
    }

    this.id = id;
  }

  public Identifier(BigInteger id) {
    this(String.format("%040x", id));
  }

  public String toHexString() {
    StringBuilder buffer = new StringBuilder(this.id.length * 2);
    for (byte b : this.id) {
      buffer.append(Integer.toHexString((b & 0xff) + 0x100).substring(1));
    }
    return buffer.toString();
  }

  public BigInteger toBigInteger() {
    return new BigInteger(1, this.id);
  }

  public byte[] toByteArray() { return this.id; }

  public byte[] getBytes() { return this.id; }

  @Override
  public String toString() { return new String(this.id); }

  @Override
  public int hashCode() { return toString().hashCode(); }

  @Override
  public boolean equals(Object other) {
    return (other != null) && (other instanceof Identifier) && equals((Identifier)other);
  }

  public boolean equals(Identifier other) {
    return MessageDigest.isEqual(this.id, other.getBytes());
  }
}
