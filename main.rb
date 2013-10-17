require 'rubygems'
require 'sinatra'

set :sessions, true

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
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop 
    session[:player_cards] << session[:deck].pop 
  end


  # deal cards
  #   player cards
  #   dealer cards

  erb :game
end