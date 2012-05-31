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
	@chunks <<  "<div class='#{name}'>"
	#puts attributes[0]
end

def end_element name
    @chunks <<  "</div> <!-- #{name} -->"
end

def comment string
	@chunks << "<!-- " << string << " -->"
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
        puts "Writing #{url}"

        parser.parse(open(url))
        
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
    body {padding-top:3%;padding-bottom:3%;}
    div.p {padding:1% 0;}
    div.i {font-style:italic;}
    div.b {font-weight:bold;}
    div.member {display:inline;font-weight:bold;}
    div.membercontribution {display:inline;}
    div.col {float:right;padding-left:2%;}
    div.col:before { content: "[Col. " }
    div.col:after { content: "]" }
	div.lb {padding:1% 0;}
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
