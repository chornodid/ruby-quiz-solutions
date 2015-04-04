require 'minitest/autorun'
require 'solitaire_cipher'

class TestSolitaireCipher < MiniTest::Test
  def test_generator

    gen = SolitaireCipher::KeyStream.new

    str1 = "DWJXH YRFDG"
    assert_equal str1, gen.build(10).to_s

    str2 =  "TMSHP UURXJ"
    assert_equal str2, gen.build(10).to_s

    str3 = str1 + " " + str2
    gen.reset
    assert_equal str3, gen.build(20).to_s
  end

  def test_encryption
    assert_equal SolitaireCipher.encrypt(''), ''

    str = "=== Code in Ruby live longer! :) ==="
    assert_equal 'GLNCQ MJAFF FVOMB JIYCB', SolitaireCipher.encrypt(str)

    str = 'AAAAA  AAAAA'
    assert_equal 'EXKYI ZSGEH', SolitaireCipher.encrypt(str)
  end

  def test_decryption
    assert_equal SolitaireCipher.decrypt(''), ''

    assert_raises(ArgumentError) { SolitaireCipher.decrypt('A') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('AB') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABC') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABCD') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABCDE -/,.0') }

    str = 'CLEPK HHNIY CFPWH FDFEH'
    assert_equal 'YOURC IPHER ISWOR KINGX', SolitaireCipher.decrypt(str)

    str = 'ABVAW LWZSY OORYK DUPVH'
    assert_equal  'WELCO METOR UBYQU IZXXX', SolitaireCipher.decrypt(str)
  end
end
