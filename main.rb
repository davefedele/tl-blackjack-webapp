require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do

  def calculate_total(cards) # cards is [['D', '4'], ['H', 'A'] ...]
    arr = cards.map {|e| e[1]}

    total = 0

    arr.each do |value|
      if value == 'A'
        total += 11
      else 
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    #correct for Aces
    arr.select {|v| v == 'A'}.count do
      break if total <= 21
      total -=10
    end

    total
  end

end


before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    erb :username
  end
end

get '/username' do
  erb :username
end

post '/username' do
  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do
  # deck 
  suits = ['H', 'D', 'C', 'S']
  values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle! # cards is [['D', '4'], ['H', 'A'] ...]

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop 
    session[:player_cards] << session[:deck].pop 
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop 
  if calculate_total(session[:player_cards]) > 21
    @error = "You busted!"
    @show_hit_or_stay_buttons = false
  elsif calculate_total(session[:player_cards]) == 21
    @sucess = "Blackjack! Congratulations #{session[:player_name]}, you win!"
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You have chosen to stay #{session[:player_name]}."
  @show_hit_or_stay_buttons = false
  erb :game
end