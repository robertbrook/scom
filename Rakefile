require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
end

class MyDocument < Nokogiri::XML::SAX::Document

def initialize
        @chunks = ""
end

attr_reader :chunks

def chunk(this)
	@chunks << this
end

def start_element name, attributes = []
        case name
        when 'p','i','b','tr','td','ol','li','section','ul' then chunk "<#{name}>"
        when 'member' then chunk  "<span class='member'>"
        when 'membercontribution' then chunk  "<span class='membercontribution'>"
        when 'memberconstituency' then chunk  "<span class='memberconstituency'>"
        when 'table'
                chunk  "<table class='table table-striped'>"
        when 'date'
                chunk  "<time>"
        when 'bill'
                chunk  "<div class='page-header'><h1>"
        when 'lb'
                chunk  "<br><br>"
        when 'quote'
                chunk  "<br><blockquote><p>"
        when 'col'
                chunk  "<span class='label label-info column' rel='tooltip' title='Column number'>Col. "
        when 'image'
                chunk '<span class="label imageref" rel="tooltip" title="Image source: ' << attributes[0][1] << '">Image</span>'
		
        when 'frontpage','standing_committee','housecommons','hansard','debates'
                chunk  "<div class='#{name}'>"
        else
                chunk  "<div class='#{name}'><span class='label label-warning'>#{name}</span>
"
        end
        
        if attributes.length > 0
	        # puts attributes.inspect
	end

end

def end_element name
        case name
        when 'p','i','b','table','tr','td','ol','li','section','ul'
                chunk  "</#{name}>"
        when 'member','membercontribution','memberconstituency'
                chunk  "</span>"
        when 'date'
                chunk  "</time>"
        when 'bill'
                chunk  "</h1></div>"
        when 'quote'
                chunk  "</p></blockquote>"
        when 'col'
                chunk  "</span>"
        when 'image','lb'
                ''
        else
                chunk  "</div> <!-- #{name} -->"
        end
    
end

def characters string
	@chunks << string
end

end

task :default do
	p "Hello world."
end


desc "Download XML inputs"
task :xml do
	mkdir_p("./input/")
	logger.info("Wrote /input/")
	Parallel.map(IO.readlines('urls.txt'), :in_threads=>30) do |url|
				
		oFile = File.open("./input/" + File.basename(url).chomp!, 'w')
		logger.info("? #{url}")

		oFile.write(open(url).read)
		logger.info("+ #{url}")

		oFile.close
		logger.info("- #{url}")
	end


end

desc "Generate HTML outputs"
task :html do
	mkdir_p("./output/")
	logger.info("Wrote /output/")
	Dir.glob('./input/*.xml').each do |xml_file|
		myfilename = File.basename(xml_file, ".xml")
		myfilename_year = myfilename.split("-")[0][2..-1]
		myfilename_cttee = 'standing-committee-' + myfilename.split("-")[1][4..-1][0,1]
		myfilename_trailing = myfilename.split("-")[1][9..-1] + ".html"
	 	FileUtils.mkpath("./output/#{myfilename_cttee}/#{myfilename_year}/")
	    	myfile = File.new("./output/#{myfilename_cttee}/#{myfilename_year}/" + myfilename_trailing, "w")
		myDoc = MyDocument.new
        	parser = Nokogiri::XML::SAX::Parser.new(myDoc)
        	parser.parse(open(xml_file))
        
        	logger.info("Parsed #{xml_file}")

        header = <<END
<!DOCTYPE html>
<html lang="en-GB">
        <head>
                <meta charset="utf-8">
                <title>#{myfilename_cttee}: #{myfilename_year}: #{myfilename_trailing}</title>
                <style>
                body {padding:3%;width:800px;margin:8px auto;font-size:larger;}
                span.member {font-weight:bold;}
                span.memberconstituency {font-weight:bold;}
                span.column {float:right;margin-left:0.2em;}
                span.imageref {margin-left:0.2em;float:right;}
                time {background-color:yellow;}
                </style>
        </head>
        <body>
	<h3 class="alert-heading">Committee Sitting HTML Preview</h3>
  	<p>XML source: #{xml_file}</p>
  	<p>File generated: #{Time.now}</p>
			
END

        myfile.write header
        myfile.write myDoc.chunks
        footer = <<END
</body>
</html>
END
        myfile.write footer
	end
end



  
  
