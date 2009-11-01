import org.specs._
import org.bitcache._
import java.io._
import java.math.BigInteger
import java.security.ProviderException

object IdentifierSpec extends Specification("Identifier") {
  def bytesToHex(id: Identifier): String   = bytesToHex(id.toByteArray)
  def bytesToHex(bytes: Seq[Byte]): String = bytes.map(b => "%02X".format(b)).mkString.toLowerCase

  val emptyData   = new Array[Byte](0)
  val emptyID     = Identifier.forBytes(emptyData)
  val emptyHex    = "da39a3ee5e6b4b0d3255bfef95601890afd80709"
  val emptyInt    = new BigInteger("1245845410931227995499360226027473197403882391305")

  val helloData   = "Hello, world!"
  val helloID     = Identifier.forBytes(helloData.getBytes("US-ASCII"))
  val helloHex    = "943a702d06f34599aee1f8da8ef9f7296031d699"

  val tempFile    = File.createTempFile("org.bitcache.", null); tempFile.deleteOnExit()

  "Identifiers" should {
    "support the SHA-1 digest algorithm" in {
      Identifier.getDigestAlgorithm("SHA-1") must notBeNull
      Identifier.getDigestAlgorithm("SHA-123") must throwA[ProviderException]
      Identifier.getDigestAlgorithm must notBeNull
      Identifier.getDigestLength("SHA-1") mustBe 20
      Identifier.getDigestLength("SHA-123") must throwA[ProviderException]
      Identifier.getDigestLength mustBe 20
    }

    "be computable from file data" in {
      val out = new FileOutputStream(tempFile)
      out.write(helloData.getBytes)
      out.close()
      bytesToHex(Identifier.forFile(tempFile)) must be equalTo helloHex
    }

    "be computable from input stream data" in {
      val stream = new ByteArrayInputStream(helloData.getBytes)
      bytesToHex(Identifier.forStream(stream)) must be equalTo helloHex
    }

    "be computable from input channel data" in {
      val out = new FileOutputStream(tempFile)
      out.write(helloData.getBytes)
      out.close()
      val in = new FileInputStream(tempFile)
      bytesToHex(Identifier.forChannel(in.getChannel())) must be equalTo helloHex
    }

    "be computable from byte buffer data" in {
      val buffer = java.nio.ByteBuffer.wrap(helloData.getBytes)
      bytesToHex(Identifier.forBuffer(buffer)) must be equalTo helloHex
    }

    "be computable from byte array data" in {
      bytesToHex(Identifier.forBytes(helloData.getBytes)) must be equalTo helloHex
    }

    "be instantiable from a hexadecimal string" in {
      new Identifier("") must throwA[IllegalArgumentException]
      new Identifier("0" * 40).toHexString must be equalTo "0" * 40
      new Identifier(emptyHex).toHexString must be equalTo emptyHex
    }

    "be instantiable from a byte array" in {
      new Identifier("".getBytes) must throwA[IllegalArgumentException]
      new Identifier(emptyID.getBytes).toHexString must be equalTo emptyHex
    }

    "be instantiable from a large integer" in {
      new Identifier(BigInteger.ZERO).toBigInteger must be equalTo BigInteger.ZERO
      new Identifier(BigInteger.ZERO).toHexString must be equalTo "0" * 40
      new Identifier(emptyInt).toBigInteger must be equalTo emptyInt
      new Identifier(emptyInt).toHexString must be equalTo emptyHex
    }

    "have well-defined equality semantics" in {
      emptyID mustNotBe helloID
      emptyID must be equalTo Identifier.forBytes("".getBytes)
      helloID must be equalTo Identifier.forBytes(helloData.getBytes("US-ASCII"))
      // TODO
    }

    "be convertible to a hexadecimal string" in {
      bytesToHex(emptyID) must be equalTo emptyHex
      emptyID.toHexString.length mustBe 40
      emptyID.toHexString must be equalTo emptyHex
    }

    "be convertible to a raw string" in {
      emptyID.toString.length mustBe 20 // FIXME: dependent on encoding?
    }

    "be convertible to a byte array" in {
      emptyID.getBytes.length mustBe 20
    }

    "be convertible to a large integer" in {
      new Identifier("0" * 40).toBigInteger must be equalTo BigInteger.ZERO
      emptyID.toBigInteger must be equalTo emptyInt
    }
  }
}
