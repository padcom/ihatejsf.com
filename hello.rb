require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'dm-timestamps'
require 'mongo'

class Logger
	def self.initialize
		uri = URI.parse(ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/ihatejsf")
		db = Mongo::Connection.new(uri.host, uri.port).db(uri.path[1..-1])
		if not uri.user.nil?
			db.authenticate(uri.user, uri.password)
		end
		if db.collection_names.include?("log")
			@@collection = db.collection("log")
		else
			@@collection = db.create_collection("log", :capped => true, :size => 100000, :max => 1000)
		end
		@@posts = db.collection("posts")
		@@counters = db.collection("counters")
	end

	def self.log(s)
		@@collection.save({
			:timestamp => Time.now.utc,
			:message   => s
		})
	end
	
	def self.posts
	    @@posts
	end
	
	def self.next_id
	    @@counters.find_and_modify({ :query => { :_id => "posts" }, :update => { "$inc" => { :sequence => 1 } } })
	end
end

Logger.initialize

get '/' do
  Logger.log("GET /")
  @posts = Logger.posts.find.sort([[ 'created', 'descending' ]])
  erb :index
end

post '/complain' do
  Logger.log("POST /complain")
  Logger.posts.insert({
    :_id => Logger.next_id,
    :author => params[:nick],
    :text => params[:text],
    :created => Time.new
  })
  "OK"
end

get '/list' do
  Logger.log("GET /list")
  @posts = Logger.posts.find.sort([[ 'created', 'descending' ]])
  erb :posts, :layout => false
end

get '/post/:id' do
  Logger.log("GET /post/" + params[:id])
  post = Logger.posts.find_one({ :_id => Integer(params[:id]) })
  if post
    erb :single_post, :locals => { :post => post }
  else
    Logger.log("post with id " + params[:id] + " not found - returning index")
    @posts = Logger.posts.find.sort([[ 'created', 'descending' ]])
    erb :index
  end
end
