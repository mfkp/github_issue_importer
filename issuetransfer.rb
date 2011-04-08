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
		getGforgeIssues(@url)
	end

	def getGforgeIssues(url)
		gforgeURL = 'http://gforge.unl.edu'
		page = Nokogiri::HTML(open(url))

		#First, get the category links from the main page
		rows = page.search('.main .tabular tr')
		rows = rows[7..rows.size-2]
		rows.each do |row|
			cells = row.search('td')
			if (cells[cells.size-2])
				items = cells[cells.size-2].text
				puts 'items: ' + items
			end
			row.search('td a').each do |link|
				tag = link.text
				tag.strip!
				puts tag + ": " + gforgeURL + link[:href]
			end
		end

		page.search('.tabular tr').each do |row|
			row.search('//td').each do |cell|
				#puts cell.content
			end
		end
	end

	def newIssue(title, body)
		options = {:body => {:title => title, :body => body, :login => @login, :token => @token}}
		#self.class.post('/issues/open/'+@pushToUser+'/'+@project, options)
	end
end

GitHub.new.newIssue('some title', 'issue text')
