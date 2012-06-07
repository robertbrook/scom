require 'rubygems'
require 'nokogiri'
require 'logger'
require 'fileutils'

@log = Logger.new(STDOUT)
@log.level = Logger::DEBUG
@log.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
end


class MyDocument < Nokogiri::XML::SAX::Document

def initialize
        @chunks = ""
end

attr_reader :chunks

def end_document
	""
end

def start_element name, attributes = []
        case name
        when 'p','i','b','tr','td','ol','li','section'
                @chunks <<  "\n\t<#{name}>"
        when 'table'
                @chunks <<  "\t<table class='table table-striped'>"
        when 'date'
                @chunks <<  "\t<time>"
        when 'lb'
                @chunks <<  "\n<br><br>"
        when 'quote'
                @chunks <<  "\t<br><blockquote><p>"
        when 'col'
                @chunks <<  "\t<span class='label label-info column'>"
        when 'image'
                @chunks << '<span class="label imageref" title="' << attributes[0][1] << '">JPEG</span>'
        when 'frontpage'
                @chunks <<  "\n\t<div class='frontpage'>"
        else
                @chunks <<  "\n\t<div class='#{name}'>"
        end

	
	#puts attributes[0]
end

def end_element name
        case name
        when 'p','i','b','table','tr','td','ol','li','section'
                @chunks <<  "</#{name}>"
        when 'date'
                @chunks <<  "</time>"
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
	@chunks << "<!-- " << string << " -->\n"
end

def characters string
	@chunks << string
end

end

Dir.glob('./input/*.xml') do |xml_file|
        myfilename = File.basename(xml_file, ".xml")
        myfile = File.new("./output/" + myfilename + ".html", "w")
        # FileUtils.mkpath("./output/#{myfilename.split("-")[0]}/#{myfilename.split("-")[1]}/")
        
        myDoc = MyDocument.new
        parser = Nokogiri::XML::SAX::Parser.new(myDoc)
        parser.parse(open(xml_file))
        
        @log.info("Parsed #{xml_file}")

        header = <<END
<!DOCTYPE html>
<html lang="en-GB">
        <head>
                <meta charset="utf-8">
                <title>#{myfilename}</title>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <link href="../css/bootstrap.min.css" rel="stylesheet">
                <link href="../css/bootstrap-responsive.min.css" rel="stylesheet">
                <!--[if lt IE 9]>
                <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
                <![endif]-->
                <style>
                body {padding:1em 0;}
                div.bill {font-weight:bold;font-size:larger;text-align:center;}
                div.member {display:inline;font-weight:bold;}
                div.memberconstituency {display:inline;font-weight:bold;}
                div.membercontribution {display:inline;}
                span.column {float:right;margin-left:0.5em;}
                span.imageref {margin-left:0.5em;float:right;}
                div.frontpage {border:1pt dotted gray;padding:20px;margin-top:10px;margin-bottom:10px;}
                </style>
        </head>
        <body>

        <div class="container">
                <div class="row">
                        <div class="span8 offset1">
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
        @log.info("Written #{myfilename}")
        

       
end
