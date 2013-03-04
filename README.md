hellish_hangman
===============

Welcome to hellish hangman, the game of hangman that will 
whittle your will away. Do your best to beat the computer, 
it's harder than it seems.

## Explanation

As you could guess, this isn't your average game of hangman. 
In this game, the computer will cheat, putting off picking a
word until the last possible moment. The computer starts out
with a dictianary of wards. First you pick a word length, then 
the computer narrows down the list to words matching that word
length. Then, every time you pick a letter, it splits up the 
dictionary into several lists of words based on possible placements
of the guessed letter. Once all the lists are made, it chooses
the larger one and says your letter was placed where it matches
that list. Without _debug_ set to true, this game is built to
look like a traditional game of hangman.
