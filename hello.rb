require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.db")

class Post
  include DataMapper::Resource

  property :id, Serial
  property :title, String
end

DataMapper.auto_upgrade!

get '/' do
  @posts = Post.all
  erb :index
end

post '/new' do
  Post.create(:title => params[:title]) 
  redirect to("/")
end
