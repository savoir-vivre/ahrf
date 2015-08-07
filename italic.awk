#!/usr/bin/awk -f

BEGIN { FS = "[\t ]"; RS = "\n\n+" }

# Italic
function italic(){
	for(i=1; i<=NF; i++) {
		italy=match($i, /(^| )\/[^ \/][^ ]*[^ \/]\/( |\.|\,|\;|\?|\!|$)/)
		if(italy) {
			gsub(/[\t ]\//," <i>",$i)
			gsub(/^\//,"<i>",$i)
			gsub(/\/[\t ]/,"</i> ",$i)
			gsub(/\/\./,"</i>.",$i)
			gsub(/\/\,/,"</i>,",$i)
			gsub(/\/\;/,"</i>;",$i)
			gsub(/\/\?/,"</i>?",$i)
			gsub(/\/\!/,"</i>!",$i)
			gsub(/\/$/,"</i>",$i)
		}
	}
}
function italic_mf(){
	for(i=1; i<=NF; i++) {
		italy=match($i, /(^| )\/\/[^ \/]+|[^ \/]+\/\/( |\.|\,|\;|\?|\!|$)/)
		if(italy) {
			gsub(/[\t ]\/\//," <i>",$i)
			gsub(/^\/\//,"<i>",$i)
			gsub(/\/\/[\t ]/,"</i> ",$i)
			gsub(/\/\/\./,"</i>.",$i)
			gsub(/\/\/\,/,"</i>,",$i)
			gsub(/\/\/\;/,"</i>;",$i)
			gsub(/\/\/\?/,"</i>?",$i)
			gsub(/\/\/\!/,"</i>!",$i)
			gsub(/\/\/$/,"</i>",$i)
		}
	}
}

/^<p>/,/^<\/p>/ {
	italic()
	italic_mf()
	print
	next
}

{ print }
