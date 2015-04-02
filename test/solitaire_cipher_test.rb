require 'minitest/autorun'
require 'solitaire_cipher'

class TestSolitaireCipher < MiniTest::Test
  def test_generator

    gen = SolitaireCipher::SequenceGenerator.new

    seq1 = "DWJXH YRFDG"
    assert_equal seq1, gen.build(10).to_s

    seq2 =  "TMSHP UURXJ"
    assert_equal seq2, gen.build(10).to_s

    seq3 = seq1 + " " + seq2
    gen.reset
    assert_equal seq3, gen.build(20).to_s
  end

  def test_encryption
    assert_equal SolitaireCipher.encrypt(''), ''

    str = "=== Code in Ruby live longer! :) ==="
    assert_equal SolitaireCipher.encrypt(str), 'GLNCQ MJAFF FVOMB JIYCB'

    str = "AAAAA  AAAAA"
    assert_equal SolitaireCipher.encrypt(str), "EXKYI ZSGEH"
  end

  def test_decryption
    assert_equal SolitaireCipher.decrypt(''), ''

    assert_raises(ArgumentError) { SolitaireCipher.decrypt('A') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('AB') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABC') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABCD') }
    assert_raises(ArgumentError) { SolitaireCipher.decrypt('ABCDE -/,.0') }

    str = 'CLEPK HHNIY CFPWH FDFEH'
    assert_equal SolitaireCipher.decrypt(str), 'YOURC IPHER ISWOR KINGX'

    str = 'ABVAW LWZSY OORYK DUPVH'
    assert_equal SolitaireCipher.decrypt(str), 'WELCO METOR UBYQU IZXXX'
  end
end
