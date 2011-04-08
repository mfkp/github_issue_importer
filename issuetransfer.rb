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
		gforgeBaseURL = 'http://gforge.unl.edu'
		page = Nokogiri::HTML(open(url))

		#First, get the category links from the main page
		rows = page.search('.main .tabular tr')
		rows = rows[7..rows.size-2]
		rows.each do |row|
			cells = row.search('td')
			items = cells[cells.size-2].text.to_i
			link = row.search('td a').first
			text = link.text.to_s
			tag = text.squeeze(" ").strip
			start = 0
			puts tag
			puts 'items: ' + items.to_s
			#Second, visit each page and pull all the issue links
			while (items > 0)
				url = gforgeBaseURL + link[:href] + '&start=' + start.to_s
				puts url
				start += 25
				items -= 25
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
