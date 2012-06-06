require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'

class MyDocument < Nokogiri::XML::SAX::Document

def initialize
    @chunks = ""
end

attr_reader :chunks

def end_document
	# puts "the document has ended"
end

def start_element name, attributes = []
        case name
        when 'p','i','b','table','tr','td','ol','li','section'
                @chunks <<  "\n\t<#{name}>"
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
                @chunks <<  "\n\t<div class='frontpage well'>"
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

IO.readlines('urls.txt').each do |url|
        
        uri = URI(url) 
        myfilename = File.basename(uri.path, ".xml")
        myfile = File.new("./output/" + myfilename + ".html", "w")
        myDoc = MyDocument.new
        parser = Nokogiri::XML::SAX::Parser.new(myDoc)

        parser.parse(open(url))
        puts "Parsing #{url}"
        header = <<END
        <!DOCTYPE html>
<html lang="en-GB">
<head>
	<meta charset="utf-8">
	<title>#{myfile}</title>
	 <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <link href="http://robertbrook.com/css/bootstrap.min.css" rel="stylesheet">
<link href="http://robertbrook.com/css/bootstrap-responsive.min.css" rel="stylesheet">
<!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
    
    <style>
    body {padding:1em 0;}
    div.member {display:inline;font-weight:bold;}
    div.membercontribution {display:inline;}
    span.column {float:right;margin-left:0.5em;}
    span.imageref {margin-left:0.5em;float:right;}
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

</body>
</html>
END
        myfile.write footer

       
end
