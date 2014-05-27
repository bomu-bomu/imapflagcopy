#! /usr/bin/env ruby

require 'sinatra'
require 'json'
require 'fileutils'
require 'rack/utils'

set :bind, '0.0.0.0'

get '/' do
	"Hello Test"
end


get '/imap_convert' do
	if request.xhr? 
		filename = params[:file]
		pid = params[:p]
		finish = ""
		realpath = "/tmp/#{filename}"
		if File.exists? realpath
			content =  `tail -50 #{realpath}`
			@finish = ""
			begin 
				Process.kill 0, pid.to_i
			rescue Errno::ESRCH
				@finish = "Finish"
				FileUtils.rm realpath
			end
			halt 200, {:output => Rack::Utils.escape_html(content), :finish => @finish}.to_json
		end
		halt 200
	end
	erb :form
end

post '/imap_convert' do
	@username = params[:username]
	password = params[:password].gsub(/;/, '\;')
	criteria = params[:criteria]
	folder = params[:folder]

	crit_opt = (criteria == 'all') ? '' : '--unseen'
	folder_opt = (folder == 'all') ? '' : '--folder INBOX'
	
	@filename = "imap_#{@username}.out"
    @pid = fork do
		system("./imap_copy.rb #{folder_opt} #{crit_opt} --password #{password} #{@username} > /tmp/#{@filename} 2>&1 ")
	end
	## Detech child  or it will become ZOMBIE process
	Process.detach @pid
	erb :progress	
end

