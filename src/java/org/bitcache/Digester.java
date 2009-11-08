package org.bitcache;
import java.security.DigestException;
import java.security.MessageDigest;

public class Digester {
  private final MessageDigest algorithm;
  private final int length;
  private byte[] digest;

  public Digester() { this(Identifier.ALGORITHM); }

  public Digester(String algorithm) {
    this.algorithm = Identifier.getDigestAlgorithm(algorithm);
    this.length    = this.algorithm.getDigestLength();
    this.digest    = new byte[this.length];
  }

  public byte[] identify(byte[] data) throws DigestException {
    algorithm.reset();
    algorithm.update(data);
    algorithm.digest(digest, 0, length);
    return digest;
  }
}
