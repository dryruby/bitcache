package org.bitcache.util;
import java.io.InputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

class ByteBufferInputStream extends InputStream {
  ByteBuffer buffer;

  ByteBufferInputStream(ByteBuffer buffer) {
    this.buffer = buffer;
  }

  @Override
  public int available() throws IOException {
    return buffer.remaining();
  }

  public int read() throws IOException {
    return buffer.hasRemaining() ? buffer.get() : -1;
  }

  @Override
  public int read(byte[] bytes, int off, int len) throws IOException {
    len = Math.min(len, buffer.remaining());
    buffer.get(bytes, off, len);
    return len;
  }
}
