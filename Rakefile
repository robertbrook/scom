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

def cdata_block string
		puts "CDATA: " + string
end

def start_document
		puts "Start of document"
end

def end_document
		puts "End of document"
end

def start_element name, attributes = []
        case name
        when 'p','i','b','tr','td','ol','li','section'
                @chunks <<  "\t<#{name}>"
        when 'table'
                @chunks <<  "\t<table class='table table-striped'>"
        when 'date'
                @chunks <<  "\t<time>"
        when 'bill'
                @chunks <<  "\t<div class='page-header'><h1>"
        when 'lb'
                @chunks <<  "\n<br><br>"
        when 'quote'
                @chunks <<  "\t<br><blockquote><p>"
        when 'col'
                @chunks <<  "\t<span class='label label-info column'>"
        when 'image'
                @chunks << '<span class="label imageref" title="' << attributes[0][1] << '">JPEG</span>'
        when 'frontpage'
                @chunks <<  "\t<div class='frontpage'>"
        else
                @chunks <<  "\t<div class='#{name}'>"
        end

	
	#puts attributes[0]
end

def end_element name
        case name
        when 'p','i','b','table','tr','td','ol','li','section'
                @chunks <<  "</#{name}>"
        when 'date'
                @chunks <<  "</time>"
        when 'bill'
                @chunks <<  "</h1></div>"
        when 'quote'
                @chunks <<  "</p></blockquote>"
        when 'col'
                @chunks <<  "</span>"
        when 'image'
                @chunks <<  "<!-- #{name} -->"
        when 'lb'
                @chunks <<  "<!-- lb -->"
        else
                @chunks <<  "</div> <!-- #{name} -->"
        end
    
end

def comment string
	puts "Comment: " + string
end

def error string
	puts "Error: " + string
end

def characters string
	@chunks << string
end

end


desc "Download XML input files"
task :download_xml do
	mkdir_p("./input/")
	logger.info("Wrote /input/")
	IO.readlines('urls.txt').each do |url|
		logger.info("Attempting #{url}")		
		File.open("./input/" + File.basename(url).chomp!, 'w') {|f| f.write(open(url).read) }
		logger.info("Downloaded #{url}")
	end
end

desc "Generate HTML output files"
task :generate_html do
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
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <link href="http://robertbrook.com/css/bootstrap.min.css" rel="stylesheet">
				<link href="http://robertbrook.com/css/bootstrap-responsive.min.css" rel="stylesheet">
                <link href="../css/bootstrap.min.css" rel="stylesheet">
                <link href="../css/bootstrap-responsive.min.css" rel="stylesheet">
                <!--[if lt IE 9]>
                <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
                <![endif]-->
                <style>
                body {padding:20px 0;}
                div.member {display:inline;font-weight:bold;}
                div.memberconstituency {display:inline;font-weight:bold;}
                div.membercontribution {display:inline;}
                span.column {float:right;margin-left:0.5em;}
                span.imageref {margin-left:0.5em;float:right;}
                div.frontpage {border:1pt dotted gray;padding:20px;margin-top:10px;margin-bottom:10px;}
                div.members_attended {border:1pt dotted gray;padding:20px;margin-top:10px;margin-bottom:10px;}
                </style>
        </head>
        <body>

        <div class="container">
                <div class="row">
                        <div class="span8 offset1">
                        <div class="alert alert-info">
  							<h4 class="alert-heading">Committee Sitting HTML Preview</h4>
  								Original XML File: #{xml_file}.<br>
  								File generated: #{Time.now}
							</div>
END

        myfile.write header
        myfile.write myDoc.chunks
        footer = <<END
</div>
</div>
</div>
</div>
    <script src="../js/jquery-1.7.2.min.js"></script>
    <script src="../js/bootstrap.min.js"></script>
</body>
</html>
END
        myfile.write footer
	end
end




  
  