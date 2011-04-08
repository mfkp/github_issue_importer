#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'httparty'

class GitHub
	include HTTParty
	base_uri 'http://github.com/api/v2/json'
	
	def initialize
		puts 'Tracker URL to be imported (example: http://gforge.unl.edu/gf/project/unl_mediayak/tracker/ ):'
		@url = STDIN.gets
		puts 'Import issues to which github project?'
		@project = STDIN.gets
		puts 'Which user owns this project?'
		@pushToUser = STDIN.gets
		File.open('credentials.config', 'r') do |config|  
		  @login = config.gets
		  @token = config.gets
		end  
		getIssues(@url)
	end

	def getIssues(url)
		page = Nokogiri::HTML(open(url))
		page.search('.tabular tr').each do |row|
			row.search('//td').each do |cell|
				puts cell.content
			end
		end
	end

	def newIssue(title, body)
		options = {:body => {:title => title, :body => body, :login => @login, :token => @token}}
		#self.class.post('/issues/open/'+@pushToUser+'/'+@project, options)
	end
end

GitHub.new.newIssue('some title', 'issue text')
