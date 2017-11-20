require 'open-uri'
require 'json'



class WordsController < ApplicationController
  def game
    @grid = generate_grid(8)
    @start_time = Time.now
  end

  def score
    @tries = session[:tries].to_a


    @answer = params[:answer]
    @start_time = DateTime.parse(params[:start_time])
    @grid = params[:grid]
    @end_time = Time.now
    @result = run_game(@answer, @grid, @start_time, @end_time)
    @try = ["grid" => @grid, "time" => @result[:time], "answer" => @answer, "score" => @result[:score]]
    @tries << @try
    session[:tries] = @tries

    @nb_games = @tries.length
    @sum_score = 0
    @sum_time = 0
    @tries.each { |try|
      @sum_score += try[0]["score"]
      @sum_time += try[0]["time"]
    }
    @average_score = (@sum_score / @nb_games)
    @average_time = (@sum_time / @nb_games)


  end

  def generate_grid(grid_size)
      # TODO: generate random grid of letters
      array = []
      grid_size.times do
        array << [*"A".."Z"].sample
      end
      array
    end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user = JSON.parse(open(url).read)
    timer = (end_time - start_time)

    if user["found"] == true && grid_match?(attempt, grid) == true
      { score: (attempt.length / timer * 100).round(2), time: timer, message: "Your answer: #{attempt}. Well done! " }
    elsif user["found"] == true && grid_match?(attempt, grid) == false
      { score: 0, time: (end_time - start_time), message: "#{attempt} is not in the grid" }
    else
      { score: 0, time: (end_time - start_time), message: "#{attempt} is not an english word" }
    end
  end

  def grid_match?(attempt, grid)
    attempt_array = attempt.upcase.split('')
    attempt_array.each do |letter|
      return false if attempt_array.count(letter) > grid.count(letter)
    end
    return true
  end

end
