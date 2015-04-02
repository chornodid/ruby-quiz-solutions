
class SolitaireCipher

  DICTIONARY = ('A'..'Z').to_a.freeze
  DICTIONARY_SIZE = DICTIONARY.size.freeze
  GROUP_LENGTH = 5.freeze
  PADDING = 'X'.freeze

  class << self
    def encrypt(text)
      raw_stream = Sequence.new(text)
      key_stream = SequenceGenerator.new().build(raw_stream.length)
      raw_stream.add(key_stream).to_s
    end

    def decrypt(text)
      check_encrypted_text text
      enc_stream = Sequence.new(text)
      key_stream = SequenceGenerator.new().build(enc_stream.length)
      enc_stream.subtract(key_stream).to_s
    end

    private

      def check_encrypted_text(text)
        letters = text.gsub(' ','').split('')
        raise ArgumentError unless letters.all? { |l| DICTIONARY.include?(l) }
        raise ArgumentError unless letters.length % GROUP_LENGTH == 0
      end
  end

  class Sequence
    include Enumerable

    def initialize(text)
      @letters = text.upcase.split("").find_all { |c| DICTIONARY.include? c }
      padding_length.times { @letters << PADDING }
    end

    def length
      @letters.size
    end

    def add(other)
      raise ArgumentError, 'sequences have different lengthes' \
        unless length == other.length

      new_letters = zip(other).map { |l1, l2| add_letters(l1, l2) }.join('')
      self.class.new(new_letters)
    end

    def subtract(other)
      raise ArgumentError, 'sequences have different lengthes' \
        unless length == other.length

      new_letters = zip(other).map { |l1, l2| subtract_letters(l1, l2) }.join('')
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

    protected

      def <<(letter)
        @letters << letter
      end

    private

      def padding_length
        (GROUP_LENGTH - length.remainder(GROUP_LENGTH)) % GROUP_LENGTH
      end

      def add_letters(letter1, letter2)
        i = (DICTIONARY.index(letter1) + DICTIONARY.index(letter2) + 2) \
          % DICTIONARY_SIZE
        DICTIONARY.at(i - 1)
      end

      def subtract_letters(letter1, letter2)
        i = (DICTIONARY.index(letter1) - DICTIONARY.index(letter2)) \
          % DICTIONARY_SIZE
        i += DICTIONARY_SIZE unless i>0
        DICTIONARY.at(i - 1)
      end
  end

  class SequenceGenerator
    INITIAL_DECK = ((1..52).to_a << :a << :b).freeze
    DECK_SIZE = INITIAL_DECK.size

    def initialize
      reset
    end

    def reset
      @deck = INITIAL_DECK.dup
      @iter = 0
      self
    end

    def build(length)
      letters = []
      while letters.length < length do
        number = next_number
        letters << DICTIONARY[(number - 1) % DICTIONARY_SIZE] if number
      end

      Sequence.new(letters.join(''))
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

        card = @deck[card_value(@deck[0])]
        card = @deck[-1] if card.nil?

        #puts 'pick card'
        #puts '--------------'
        #puts card_value(card)

        return nil if card == :a || card == :b
        card_value(card)
      end

      def card_value(card)
        case card
        when :a then 53
        when :b then 54
        else card
        end
      end

      def move_forward(card, by_step)
        from = @deck.index(card)
        by_step.times do
          if from == DECK_SIZE - 1
            @deck.pop
            top_card = @deck.shift
            @deck.unshift card
            @deck.unshift top_card
            from = 1
          else
            to = from + 1
            @deck[from] = @deck[to]
            @deck[to] = card
            from = to
          end
        end
        check_deck
        nil
      end

      def perform_triple_cut
        top, bottom = [@deck.index(:a), @deck.index(:b)].minmax

        #puts 'perform triple cut'
        #puts 'top = '+ top.to_s + ", bottom = "+ bottom.to_s

        new_deck = @deck[top..bottom]
        new_deck = @deck[(bottom + 1)..-1] + new_deck if bottom < DECK_SIZE - 1
        new_deck = new_deck + @deck[0..(top-1)] if top > 0
        @deck = new_deck

        check_deck
        nil
      end

      def perform_count_cut
        card = @deck.pop
        @deck.rotate!(card_value(card)) << card

        check_deck
        nil
      end

      def check_deck
        raise 'invalid deck' unless @deck.uniq.size == DECK_SIZE
      end
  end
end

help_info = <<-eos
Implementation of Solitaire Cipher, http://rubyquiz.com/quiz1.html
Usage:
  [-h, --help]         - print this help
  [-e, --encrypt] text - encrypt text
  [-d, --decrypt] text - decrypt text
eos

if ARGV.size > 0
  key, *text = ARGV
  case key
  when '-h', '--help'
    puts help_info
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
