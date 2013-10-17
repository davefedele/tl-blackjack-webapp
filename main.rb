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
  erb :game
end