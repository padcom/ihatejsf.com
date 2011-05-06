require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'

get '/' do
  @message = "Hello, world! from sinatra"
  erb :index
end
