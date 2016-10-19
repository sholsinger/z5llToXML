#!/usr/bin/ruby
# z5llToXML.rb

load 'lib/CountryMap.rb'
require 'csv'
require 'libxml'

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
Z5_VERSION = 'Z5llToXML version 1.2.1'
GEOLOCATION_NS = 'http://www.demandware.com/xml/impex/geolocation/2007-05-01'

# class to encapsulate all logic for converting z5ll.txt files to DWRE Gelocation XML
class Z5llToXML
	
	def initialize(fname, cc = 'US')
		@fileName = fname
		@countryCode = cc

		@rowCount = 0
		@currentRow = 0
		@completion = 0
		@geolocations = nil
		@outputFileName = nil
		@document = nil
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
			self.writeXMLFile()
			
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
		document = LibXML::XML::Writer.file(@outputFileName)
		document.start_document :encoding => LibXML::XML::Encoding::UTF_8
		document.start_element_ns nil, 'geolocations', GEOLOCATION_NS
		#document.write_attribute 'xmlns', GEOLOCATION_NS
		document.write_attribute('country-code', @countryCode.to_s)
		document.flush
		return document
	end

	def writeXMLFile()
		#@document.write( File.new( file, "wb" ), -1, false, true )
		@document.end_element #'geolocations'
		@document.flush
	end

	def processCSVRow( row )
		@currentRow+=1
		unless row == nil || row[0].to_s.include?('Copyright') || row[0].to_s.eql?('City') || !isStateOfCurrentCountry?(row[1])
			puts( "Processing row: #{row.join(',')}" )
			unless row == nil || row.empty?
				@document.start_element 'geolocation'
				@document.write_attribute 'postal-code', row[2]
				
				@document.start_element 'city'
				@document.write_attribute_ns 'xml', 'lang', nil, 'x-default'
				@document.write_string row[0]
				@document.end_element #'city'

				@document.start_element 'state'
				@document.write_attribute_ns 'xml', 'lang', nil, 'x-default'
				@document.write_string row[1]
				@document.end_element #'state'

				@document.write_element 'longitude', row[9]
				
				@document.write_element 'latitude', row[8]
				

				@document.end_element #'geolocation'
				@document.flush
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
