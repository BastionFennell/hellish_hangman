##
#== Evil Hangman
# Welcome to evil hangman, the game of hangman that will make you pull your
# hair out. Do your best to beat the computer, it's harder than it seems.
#
#== Explanation
# As you could guess, this isn't your average game of hangman. In this game
# the computer will cheat, putting off picking the word until the last possible
# moment. The computer starts out with a dictionary of words. First you pick
# a word length, then the computer narrows down the list to the given word
# length. Then, every time you pick a letter, it splits up the dictionary into
# several lists of words, depending on the placement of the given letter.
# It then picks the largest list, and says your letter was put where it is for
# the list of letters and has you guess again. Without +debug+, this game is
# built to look like your average game of hangman.
#
#== Classes
#=== HangmanManager.rb 
# manages the actual list and any modifications to it. guesses
# are passed to it, and it returns the longest list along with several other
# helpful functions.
#
#=== HangmanHandler.rb
#
# This manages all of the functions for the game itself, such as the initialization
# of the game, taking the guesses, and seeing if their valid. It's essentially
# the front end of the program.
#
#== Documentation
#
# Author:: Bastion Fennell
# Date:: Wednesday, February 27, 2013

require './HangmanManager'

##
# This class handles the actual game play. It's the front end of the program,
# getting user input and passing it to the manager.
class HangmanHandler
  ##
  # If this is set to true, values helpful for debugging will be printed
  # to the screen
  attr_reader :debug

  ##
  # Initializes the handler to build the game with +dictionary+. If +debug+
  # is true, several values will appear that are helpful for debugging the
  # program. If it is set to false, the game will appear to be regular
  # hangman.
  def initialize(debug, dictionary)
    #File that holds all of the words for the dictionary
    @dictionary_file = File.new(dictionary, 'r')
	#The maximum number of guesses for the user
	@max_guesses = 25
    #The constant for the easy difficulty
	@easy = 1
    #The constant for the medium difficulty
	@medium = 2
    #The constant for the hard difficulty
	@hard = 3
	
    @debug = debug
  end

  ##
  # This sets all the variables for the game. It asks for user input
  # on anything that it needs, then passes it to the Manager to initialize
  # everything.
  def set_game_parameters(hangman_manager)
    word_length = 0
    begin
      print 'What length word do you want to use? '
      word_length = gets.to_i
    end until at_least_one_word?(hangman_manager, word_length)

    number_guesses = 0

    begin
      print 'How many wrong answers allowed? '
      number_guesses = gets.to_i
    end until valid_choice?(number_guesses, 1, @max_guesses, 'number of wrong guesses')

    difficulty = 0

    begin
      print "What difficulty level do you want?\n"
      print "Enter a number between #{@easy}(EASIEST) and #{@hard}(HARDEST) : "
      difficulty = gets.to_i
    end until valid_choice?(difficulty, @easy, @hard, 'difficulty')

    hangman_manager.prep_for_round word_length, number_guesses, difficulty
  end

  ##
  # This checks to see if +choice+ is between +min+ and +max+. If it isn't,
  # it prints an error based on +parameter+ and returns false.
  def valid_choice?(choice, min, max, parameter)
    valid = (min..max)===choice
    unless valid
      print "#{choice} is not a valid number for #{parameter}\n"
      print "Pick a number between #{min} and #{max}.\n"
    end
    valid
  end

  ##
  # This checks to see if there is at least one word of +word_length+ length in the
  # dictionary of +hangman_manager+.
  def at_least_one_word?(hangman_manager, word_length)
    num_words = hangman_manager.num_words word_length
    if num_words == 0
      print "I don't know any words with #{word_length} letters. Enter another number.\n"
    end

    num_words != 0
  end

  ##
  # This shows the patterns of letter placement and the corresponding number of
  # words that match that placement based on the hash +patterns+.
  def show_patterns(patterns)
    patterns.each{ |key, value| print "pattern: #{key}, number of words: #{value}\n" }
  end

  ##
  # This method actually plays the game. As long as the pattern has dashes and there
  # are guesses left, it will ask for input and pass it to +hangman+.
  def play_game(hangman)
    while hangman.guesses_left > 0 and hangman.pattern.include?('-') do
      print "guesses left: #{hangman.guesses_left}\n"

      print "DEBUGGING: words left : #{hangman.num_words_current}\n" if @debug

      print "guessed so far : #{hangman.guesses_made}\n"
      print "current word : #{hangman.pattern}\n"

      guess = get_letter(hangman)
      patterns = hangman.make_guess guess

      if @debug
        print "\n\nDEBUGGING: Based on guess here are resulting patterns and number of words in each pattern:\n"
        show_patterns patterns 
        print "END DEBUGGING\n\n"
      end		

      count = get_count(hangman.pattern, guess)
      if count == 0
        print "Sorry, there are no #{guess}'s\n\n" 
      elsif count == 1
        print "Yes, there is one #{guess}\n\n"
      else
        print "Yes, there are #{count} #{guess}'s\n\n"
      end
    end
  end

  ##
  # This method gets the users input for a letter and checks to see if it is an 
  # english letter and it hasn't been guessed yet. If either of those is false,
  # it asks for input again. If they're true, it returns the letter.
  def get_letter(manager)
    already_guessed = true
    guess = ' '
    while already_guessed do
      print 'Your guess? '
      result = gets
      while result == nil or result.length == 0 or !is_english_letter? result[0] do
        print "That is not an English letter.\n"
        print 'Your guess? '
        result = gets
      end
      guess = result[0]
      already_guessed = manager.already_guessed?(guess)

      if manager.already_guessed? guess
        print "You already guessed that! Pick a new letter please.\n"
      end
    end
    print "the guess: #{guess}."
    guess
  end

  ##
  # Simply checks to see if +ch+ is an english letter.
  def is_english_letter?(ch)
    ('a'..'z') === ch.downcase
  end

  ##
  # Returns the number of times +guess+ appears in +pattern+.
  def get_count(pattern, guess)
    result = 0
    pattern.length.times{ |index| result+=1 if pattern[index] == guess }
    result
  end

  ##
  # Returns a secret word at the end of the game. It's simply the first
  # letter in the list of active letters.
  #--
  # TODO: Have the method return a random letter from the active list.
  def show_results(hangman)
    answer = hangman.get_secret_word
    print "answer = #{answer}\n"
    if hangman.guesses_left > 0
      print 'You beat me'
    else
      print 'Sorry, you lose'
    end
  end

  ##
  # Prints the number of words for each word length between 2 and +max_letters_per_word+
  def show_word_counts(hangman)
    max_letters_per_word = 25
    (max_letters_per_word - 2).times{ |index| print "#{index} #{hangman.num_words(index)}\n"}
  end

  ##
  # Checks to see if the user wants to play another game or not.
  def play_again?
    print "\n\nAnother game? enter y for another game, anything else to quit: "
    answer = gets
    answer.delete! "\n"
    answer.downcase == 'y'
  end
  
  ##
  # Converts +@dictionary_file+ to an array and returns the value.
  def dictionary_to_array
    dictionary_list = Array.new
    @dictionary_file.each do |word|
      word.delete! "\n"
      dictionary_list << word
    end
    dictionary_list
  end
end


print "Welcome to the Ruby hangman game.\n\n"

handler = HangmanHandler.new(true, 'dictionary.txt')

dictionary_list = handler.dictionary_to_array

hang_manager = HangmanManager.new(dictionary_list)

handler.show_word_counts(hang_manager) if handler.debug

begin
  handler.set_game_parameters(hang_manager)
  handler.play_game(hang_manager)
  handler.show_results(hang_manager)
end while handler.play_again?