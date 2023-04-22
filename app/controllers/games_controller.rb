require 'open-uri'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
  end

  def score
    p @result = run_game(params[:word], params[:grid].split(' '))
  end

  def generate_grid(grid_size)
    @grid = []
    letters = ('A'..'Z').to_a

    (1..grid_size).each do
      letters.each { |letter| @grid << letter }
    end

    @grid.sample(grid_size)
  end

  def word_checker(word)
    url = 'https://wagon-dictionary.herokuapp.com/' + word
    uri = URI(url)
    p JSON.parse(uri.open.read)['found']
  end

  def in_grid_checker(word, grid)
    word.chars.each do |letter|
      return false unless grid.include? letter.upcase
    end
    true
  end

  def calculate_score(word, grid, time_to_answer, round_precision = 2)
    # SCORE = 100 if word has grid size and anwers takes exactly time_precision in seconds
    100 * ((word.size - 1).to_f / grid.size).round(round_precision) / time_to_answer
  end

  def letter_counter(word, grid)
    word.downcase.chars.each do |letter|
      if word.count(letter) > grid.join.downcase.count(letter)
        return false
      end
    end
    true
  end

  def run_game(attempt, grid)
    # only accept attempts with all letters in the grid
    return { message: "Sorry but #{attempt.upcase} cant be build out #{grid}" } unless in_grid_checker(attempt, grid)
    # only accept if attempts is a valid english word
    return { message: "Sorry but #{attempt.upcase} does not seen to be a valid english word" } unless word_checker(attempt)
    # TBC => checar se alguma letra foi usada mais vezes que o permitido
    return { message: 'Sorry, you used a letter more than allowed' } if letter_counter(attempt, grid) == false

    { message: "Contratulations! #{attempt.upcase} is a valid english word!" }
  end
end
