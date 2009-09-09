package org.bitcache;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.math.BigInteger;

public class Identifier {
  public static String ALGORITHM = "SHA-1";
  public byte[] id;

  public static Identifier forBytes(byte[] data) {
    try {
      MessageDigest digest = MessageDigest.getInstance(ALGORITHM);
      digest.update(data);
      return new Identifier(digest.digest());
    }
    catch (NoSuchAlgorithmException e) {
      return null;
    }
  }

  public Identifier(String id) {
    this.id = new byte[id.length() / 2];
    for (int i = 0; i < id.length(); i += 2) {
      this.id[i / 2] = (byte)((Character.digit(id.charAt(i), 16) << 4) +
                               Character.digit(id.charAt(i + 1), 16));
    }
  }

  public Identifier(byte[] id) {
    this.id = id;
  }

  public String toString() {
    return new String(this.id);
  }

  public String toHexString() {
    StringBuilder buffer = new StringBuilder(this.id.length * 2);
    for (byte b : this.id) {
      buffer.append(Integer.toHexString((b & 0xff) + 0x100).substring(1));
    }
    return buffer.toString();
  }

  public BigInteger toBigInteger() {
    return new BigInteger(this.id);
  }

  public byte[] getBytes() {
    return this.id;
  }

  public int hashCode() {
    return toString().hashCode();
  }

  public boolean equals(Object other) {
    return (other instanceof Identifier) && equals((Identifier)other);
  }

  public boolean equals(Identifier other) {
    return toString().equals(other.toString());
  }
}
