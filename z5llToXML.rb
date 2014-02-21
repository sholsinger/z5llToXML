#!/usr/bin/ruby
# z5llToXML.rb

require 'csv'
require 'rexml/document'
require 'lib/CountryMap.rb'
include REXML

HELP_TEXT = <<HELP
Usage: ./z5llToXML.rb <switches> <file1> <file2>

This utility is used for converting files retrieved from ZipList.com into a
usable format for Demandware Geolocation XML import. This program utilizes
the CSV and REXML modules from the Ruby Sandard Library.

Arguments:
--countries -c  A comma-separated list of 2-character country codes that 
                are contained within the input file(s).
                Note: Each file will be given 1 pass-through per country 
                code.
--version   -v  Outputs version information.
--help      -h  Outputs this help text.
HELP
Z5_VERSION = "Z5llToXML version 1.1a"

# class to encapsulate all logic for converting z5ll.txt files to DWRE Gelocation XML
class Z5llToXML
	
	def initialize(fname, cc = "US")
		@fileName = fname
		@countryCode = cc

		@rowCount = 0
		@currentRow = 0
		@completion = 0
		@geolocations = nil
	end

	# Process the file
	def process
		filePath = File.expand_path @fileName

		# check if it exists
		if File.file? filePath
			
			# notify we're processing
			puts( "Processing #{@fileName}..." )
			
			# build output filename
			@outputFileName = @fileName.gsub(/\.(txt|csv){1}/, "#{@countryCode}.xml" )
			
			# create XML Document stub
			@document = self.openXMLFile()

			# process CSV file
			CSV.foreach( filePath ) do |row|
				self.processCSVRow( row )
			end

			# write XML file to disk
			self.writeXMLFile( @outputFileName )
			
			# notify we're done
			puts( "Writing output to file #{@outputFileName}" )
			return 1
		else
			# reference isn't a real file
			puts( "Skipping non-file #{@fileName}" )
			return 0
		end
	end

	def isStateOfCurrentCountry?(state)
		return COUNTRY_MAP[@countryCode.to_s].include? state
	end

	def openXMLFile ()
		document = Document.new
		document.add_element "geolocations", {"xmlns" => "http://www.demandware.com/xml/impex/geolocation/2007-05-01", "country-code" => @countryCode.to_s }
		document << XMLDecl.new
		return document
	end

	def writeXMLFile( file )
		@document.write( File.new( file, "wb" ), -1, false, true )
	end

	def processCSVRow( row )
		@currentRow+=1
		unless row == nil || row[0].to_s.include?("Copyright") || row[0].to_s.include?("City") || !isStateOfCurrentCountry?(row[1])
			puts( "Processing row: #{row.join(',')}" )
			if @geolocations == nil
				@geolocations = @document.get_elements("//geolocations").first
			end
			unless @geolocations == nil || row == nil || row.empty?
				geolocation = @geolocations.add_element "geolocation", {"postal-code" => row[2] }
				city = geolocation.add_element "city", {"xml:lang" => "x-default"}
				city.text = row[0]
				state = geolocation.add_element "state", {"xml:lang" => "x-default"}
				state.text = row[1]
				long = geolocation.add_element "longitude"
				long.text = row[9]
				lat = geolocation.add_element "latitude"
				lat.text = row[8]
				# clear up ram
				geolocation = city = state = long = lat = nil
			end
			if @currentRow % 1000 == 0
				puts("Collecting garbage.")
				GC.start
			end
		end
	end

end

# initialize file counter
fcount = 0
# default countries
countries = 'US'

# loop through arguments
ARGV.each_index do |arg|
	# print help documentation
	if ['help', '--help', '-h'].include? ARGV[arg]
		puts HELP_TEXT
		ARGV.delete_at arg
		break
	# print version documentation
	elsif ['--version', '-v'].include? ARGV[arg]
		puts Z5_VERSION
		ARGV.delete_at arg
		break
	# set countries
	elsif ['--country', '-c'].include? ARGV[arg]
		countries = ARGV[arg+1]
		2.times do |i|
			ARGV.delete_at arg
		end
	end
end
# process the file(s)
ARGV.each do |file|
	countries.split(/,/).each do |country|
		csv = Z5llToXML.new file, country
		fcount += csv.process
	end
end
