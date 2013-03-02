##
# This object holds the dictionary of available words for the game and 
# reacts to the users guesses. Whenever a user makes a guess, it's handed
# to this object, which modifies the available words to match that guess.
class HangmanManager

  # Holds the number of guesses left for the user
  attr_reader :guesses_left
  # Holds an array of characters that have already been guessed
  attr_reader :guesses_made
  # Holds the current pattern of blanks and guessed characters
  attr_reader  :pattern

  ##
  # Initializes the object, assiging a class variable to the dictionary
  # array for use in various methods.
  def initialize words
    @word_list = words
  end

  ##
  # Returns the number of words in the word list of +size+
  def num_words(size)
    total = 0
    @word_list.each{ |word| total += 1 if word.size == size }
    total
  end

  ##
  # Prepares for the next round of the game. Creates a dictionary based
  # on the +word_size+, sets the number of guesses based on +number_guesses+, 
  # and sets the difficulty based on +diff+.	
  def prep_for_round(word_size, number_guesses, diff)
    @guesses_left = number_guesses
    @word_size = word_size
    @pattern = ''
    @guesses_made = Array.new

		
    word_size.times do
      @pattern << '-'
    end

    @active_list = Array.new
    @word_list.each{ |word| @active_list << word if word.size == word_size }

    case diff
    when 1
      @diff_timer = 1
      @timer_max = 2
    when 2
      @diff_timer = 3
      @timer_max = 4
    else
      @diff_timer = -1
      @timer_max = -1
    end
  end

  ##
  # Returns the number of words in the active word list, or the number 
  # of words that match the current pattern and guesses
  def num_words_current
    @active_list.size
  end

  ##
  # Returns the 'secret word', a value that matches the current pattern.
  def get_secret_word
    @active_list.fetch(0)
  end

  ##
  # Checks to see if the +guessed_character+ has been guessed yet
  def already_guessed?(guessed_character)
    @guesses_made.include?(guessed_character)
  end

  ##
  # Does all of the brute work for the program. This builds a hash with the key based on
  # the placement of the given character and the value as an array of words that match that
  # pattern. Then it picks the value with the largest size and sets the pattern equal to that 
  # values key.
  def make_guess(guess)
    @guesses_made << guess
    @guesses_made.sort!
    guess_list = Hash.new		

    @active_list.each do |word|
      format = @pattern.dup
      @word_size.times{ |index| format[index] = guess if word[index] == guess }

      guess_list[format] = String.new if guess_list[format] == nil
      guess_list[format] << word
      guess_list[format] << ','
    end

    guess_list = guess_list.sort

    biggest = String.new
    second_biggest = String.new
    biggest_size = -1
    second_biggest_size = -1
    hold_list = Hash.new
    guess_list.each do |key, value|
      hold_list[key] = value.split(',')	
      if biggest_size < hold_list.fetch(key).size
        biggest = key
        biggest_size = hold_list.fetch(key).size
      elsif biggest_size == hold_list.fetch(key).size
        first_reveal = 0
        second_reveal = 0
        @word_size.times do |index|
          first_reveal += 1 if biggest[index] == guess					
          second_reveal += 1 if key[index] == guess
        end
        biggest = key if first_reveal > second_reveal
      end


      if second_biggest_size < hold_list.fetch(key).size && key != biggest 
        second_biggest = key
        second_biggest_size = hold_list.fetch(key).size
      elsif biggest_size == hold_list.fetch(key).size && key != biggest
        first_reveal = 0
        second_reveal = 0
        @word_size.times do |index|
          first_reveal += 1 if second_biggest[index]== guess					
          second_reveal += 1 if key[index] == guess
        end
        second_biggest = key if first_reveal > second_reveal	
      end
    end

    output = Hash.new
    hold_list.each{ |key, value| output[key] = value.size }


    biggest = second_biggest if @diff_timer == 0 && second_biggest != String.new
			
    @active_list = hold_list.fetch(biggest)

    biggest == @pattern ? @guesses_left -= 1 : @pattern = biggest
    

    @diff_timer = @timer_max if @diff_timer == 0
			
    @diff_timer -= 1
		
    output
  end
end	