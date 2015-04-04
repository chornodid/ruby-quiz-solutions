
class SolitaireCipher

  DICTIONARY = ('A'..'Z').to_a.freeze
  DICTIONARY_SIZE = DICTIONARY.size.freeze
  GROUP_LENGTH = 5.freeze
  PADDING = 'X'.freeze

  class << self
    def encrypt(text)
      raw_stream = Stream.new(text)
      gen = KeyStream.new()
      key_stream = gen.build(raw_stream.length)
      enc_stream = raw_stream.merge(key_stream)
      enc_stream.to_s
    end

    def decrypt(text)
      check_encrypted_text text
      enc_stream = Stream.new(text)
      gen = KeyStream.new() { |number| DICTIONARY_SIZE - number }
      key_stream = gen.build(enc_stream.length)
      raw_stream = enc_stream.merge(key_stream)
      raw_stream.to_s
    end

    private

      def check_encrypted_text(text)
        letters = text.gsub(' ','').split('')
        raise ArgumentError unless letters.all? { |l| DICTIONARY.include?(l) }
        raise ArgumentError unless letters.length % GROUP_LENGTH == 0
      end
  end

  class Stream
    include Enumerable

    def initialize(data)
      if data.is_a? String
        @letters = data.upcase.split("")
      elsif data.kind_of? Enumerable
        @letters = data.dup
      else
        raise ArgumentError
      end
      @letters = @letters.select { |c| DICTIONARY.include? c }
      fill_padding
    end

    def length
      @letters.size
    end

    def merge(other)
      raise ArgumentError, 'sequences have different lengthes' \
        unless length == other.length

      new_letters = zip(other).map { |l1, l2| merge_letters(l1, l2) }
      self.class.new(new_letters)
    end

    def to_s
      each_slice(GROUP_LENGTH).map { |g| g.join('') }.join(' ')
    end

    def each
      if block_given?
        @letters.each { |l| yield l }
      else
        Enumerator.new(self, :each)
      end
    end

    private

      def fill_padding
        padding_length.times { @letters << PADDING }
      end

      def padding_length
        (GROUP_LENGTH - length.remainder(GROUP_LENGTH)) % GROUP_LENGTH
      end

      def merge_letters(letter1, letter2)
        i = (DICTIONARY.index(letter1) + DICTIONARY.index(letter2) + 2) \
          % DICTIONARY_SIZE
        DICTIONARY.at(i - 1)
      end
  end

  class KeyStream
    INITIAL_DECK = ((1..52).to_a << :a << :b).freeze
    DECK_SIZE = INITIAL_DECK.size

    def initialize(&proc)
      reset
      @proc = proc
    end

    def reset
      @deck = INITIAL_DECK.dup
      @iter = 0
      self
    end

    def build(length)
      letters = []
      length.times do
        number = next_number
        redo unless number
        number = @proc.call(number) if @proc
        letters << DICTIONARY[(number - 1) % DICTIONARY_SIZE]
      end

      Stream.new(letters)
    end

    def print_deck
      res = @deck.map do |card|
        case card
        when :a then '[A]'
        when :b then '[B]'
        else sprintf('%3d', card)
        end
      end.
      each_slice(13).map{ |g| g.join(' ') }.
      join("\n")
      puts res
    end

    private

      def next_number
        @iter += 1

        #puts '=============='
        #puts 'iter '+@iter.to_s
        #puts '--------------'

        move_forward :a, 1

        #puts 'move_forward a'
        #puts '--------------'
        #print_deck

        move_forward :b, 2

        #puts 'move_forward b'
        #puts '--------------'
        #print_deck

        perform_triple_cut

        #puts 'triple cut'
        #puts '--------------'
        #print_deck

        perform_count_cut

        #puts 'count cut'
        #puts '--------------'
        #print_deck

        card = @deck[card_rank(@deck[0])]

        #puts 'pick card'
        #puts '--------------'
        #puts card_rank(card)

        return nil if card == :a || card == :b
        card_rank(card)
      end

      def card_rank(card)
        case card
        when :a, :b then 53
        else card
        end
      end

      def move_forward(card, by)
        from = @deck.index(card)
        @deck.delete_at(from)
        to =  (from + by) % DECK_SIZE
        to = 1 if to == 0
        @deck[to, 0] = card

        #check_deck
        self
      end

      def perform_triple_cut
        top, bottom = [@deck.index(:a), @deck.index(:b)].sort
        @deck = @deck[(bottom + 1)..-1] + @deck[top..bottom] + @deck[0...top]

        #check_deck
        self
      end

      def perform_count_cut
        card = @deck.pop
        @deck.rotate!(card_rank(card))
        @deck << card

        #check_deck
        self
      end

      def check_deck
        raise 'invalid deck' unless @deck.uniq.size == DECK_SIZE
      end
  end
end

help_info = <<-eos
Implementation of Solitaire Cipher, http://rubyquiz.com/quiz1.html
Usage:
  [-e, --encrypt] text - encrypt text
  [-d, --decrypt] text - decrypt text
eos

if ARGV.size > 0
  key, *text = ARGV
  case key
  when '-e', '--encrypt'
    puts SolitaireCipher.encrypt text.join(' ')
  when '-d', '--decrypt'
    puts SolitaireCipher.decrypt text.join(' ')
  else
    puts 'Unknown key: '+key
    puts '---------------------'
    puts help_info
  end
else
  puts help_info
end
