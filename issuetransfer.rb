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
		  @gforgeBaseUrl = config.gets.chomp
		end  
		getGforgeIssues(@url)
	end

	def getGforgeIssues(url)
		page = Nokogiri::HTML(open(url))

		#First, get the category links from the main page
		rows = page.search('.main .tabular tr')
		rows = rows[7..rows.size-2]
		rows.each do |row|
			cells = row.search('td')
			items = cells[cells.size-2].text.to_i
			link = row.search('td a').first
			tag = link.text
			tag = tag[2..tag.size-1].gsub(/e*s$/, '')
			if (items > 0)
				puts tag
				puts 'items: ' + items.to_s
				#Second, visit each page and pull all the issue links
				start = 0
				while (items > 0)
					fullUrl = @gforgeBaseUrl + link[:href] + '&start=' + start.to_s
					#puts fullUrl
					page2 = Nokogiri::HTML(open(fullUrl))
					rows = page2.search('.main .tabular tr')
					rows = rows[1..rows.size-2]
					#Finally, parse through each tracker item and add it to github
					rows.each do |row|
						itemLink = row.search('td a').first
						fullItemLink = @gforgeBaseUrl + itemLink[:href]
						puts fullItemLink
						page3 = Nokogiri::HTML(open(fullItemLink))
						case tag
						when 'To-Do'
							submittedBy = page3.xpath("//a[href_matches_regex(., '.*/gf/user/.*')]", RegexHelper.new).first.to_s.gsub(/<\/?[^>]+>/, '')
							puts submittedBy
							dataTable = page3.css('table')[1].to_s
							status = dataTable.match(/Closed/).to_s || page3.css('table')[1].to_s.match(/Open/) || ''
							puts status
							title = dataTable.match(/<strong>Summary<\/strong><br\s*[\/]*>\s*(.*)\s*<\/tr>/).to_s.gsub(/<\/?[^>]+>/, '').gsub(/Summary/, '').chomp.strip || ''
							puts title
							body = page3.at_css('#details_readonly pre').to_s.gsub(/<\/?[^>]+>/, '') || ''
							puts body
							
						when 'Support'
							#parse 'support'
						when 'Patch'
							#parse 'patches'
						when 'Feature Request'
							#parse 'feature requests'
						when 'Bug'
							#parse 'bugs'
						else
							puts 'im confused'
						end
						
						puts '------------------'
						puts ''
					end
					start += 25
					items -= 25
				end
			end
		end
	end

	def newIssue(title, body)
		options = {:body => {:title => title, :body => body, :login => @login, :token => @token}}
		#self.class.post('/issues/open/'+@pushToUser+'/'+@project, options)
	end
end

class RegexHelper 
	def href_matches_regex node_set, regex_string 
		! node_set.select { |node| node['href'] =~ /#{regex_string}/ }.empty?
	end 
end 

GitHub.new.newIssue('some title', 'issue text')
