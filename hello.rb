require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'

DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.db")

class Post
  include DataMapper::Resource

  property :id, Serial
  property :text, String
  property :created_at, DateTime
end

DataMapper.auto_migrate!

get '/' do
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :index
end

post '/complain' do
  Post.create(:text => params[:text]) 
  redirect to("/")
end

get '/list' do
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :posts
end
