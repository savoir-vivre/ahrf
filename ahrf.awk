#!/usr/bin/awk -f

BEGIN { FS = "\n"; RS = "" }

# Include HTML without change
/^<[^<>]+>/ {
	print
	next
}

{
	# Common shell symbols to HTML
	# Two backslashes for nawk(1) and OpenBSD awk(1)
	gsub(/\&/,"\\&amp;")
	gsub(/</,"\\&lt;")
	gsub(/>/,"\\&gt;")
}

# h1, h2, h3, h4, h5, h6
/^[\t ]*:/ {
	match($0,":+")
	cnt = RLENGTH
	gsub(/^[\t ]*:+[\t ]*|[\t ]*:+[\t ]*$/,"")
	anc = tolower($0)
	gsub(/ +/,"-",anc)
	# length($0) would also work
	if (cnt <= 6 && $0 != "") {
		printf("<h%d id=\"%s-%s\">%s</h%d>\n", cnt, anc, n_id++, $0, cnt)
	}
	next
}

# Quote
/^----+/ {
	if (NF > 2 && $NF ~ /----+/) {
		gsub(/^[\t ]*----+[\t ]*\n|\n[\t ]*----+[\t ]*$/,"")
		printf("<div class=quote>")
		for (c=1; c<NF; c++) {
			gsub(/^ +$/,"",$c)
			printf("%s\n", $c)
		}
		printf("%s</div>\n", $NF)
	}
	next
}

# Horizontal Ruler
/^-[\t ]-([\t ]-)+/ {
	gsub(/^[\t ]*-[\t ]-([\t ]-)+/,"")
	printf("<hr>\n")
	next
}

# Italic
function italic(){
	FS = "[\t ]"
	for(i=1; i<=NF; i++) {
		italy=match($i, /(^| )\/[^ ]+\/( |\.|\,|\?|\!|$)/)
		if(italy) {
			gsub(/[\t ]\//," <i>",$i)
			gsub(/^\//,"<i>",$i)
			gsub(/\/[\t ]/,"</i> ",$i)
			gsub(/\/\./,"</i>.",$i)
			gsub(/\/\,/,"</i>,",$i)
			gsub(/\/\?/,"</i>?",$i)
			gsub(/\/\!/,"</i>!",$i)
			gsub(/\/$/,"</i>",$i)
		}
	}
	FS = "\n"
}
function italic_mf(){
	FS = "[\t ]"
	for(i=1; i<=NF; i++) {
		italy=match($i, /(^| )\/\/[^ \/]+|[^ \/]+\/\/( |\.|\,|\?|\!|$)/)
		if(italy) {
			gsub(/[\t ]\/\//," <i>")
			gsub(/^\/\//,"<i>")
			gsub(/\/\/[\t ]/,"</i> ")
			gsub(/\/\/\./,"</i>.")
			gsub(/\/\/\,/,"</i>,")
			gsub(/\/\/\?/,"</i>?")
			gsub(/\/\/\!/,"</i>!")
			gsub(/\/\/$/,"</i>")
		}
	}
	FS = "\n"
}

# Paragraph
/^[A-Za-z0-9_("{}\/„\.\$\'\-\+öäüÖÄÜ→]+/ {
	italic()
	italic_mf()
	printf("<p>")
	for (p=1; p<NF; p++) {
		if ($p ~ / +$/) {
			gsub(/ +$/,"",$p)
			printf("%s<br>\n", $p)
		} else {
			printf("%s\n", $p)
		}
	}
	printf("%s</p>\n", $p)
	next
}

# Code
/^====+/ {
	if (NF > 2 && $NF ~ /====+/) {
		gsub(/^[\t ]*====+[\t ]*\n|\n[\t ]*====+[\t ]*$/,"")
		printf("<pre><code>")
		for (c=1; c<NF; c++) {
			gsub(/^ +$/,"",$c)
			printf("%s\n", $c)
		}
		printf("%s</code></pre>\n", $NF)
	}
	next
}

# List
/^[\t ]*\* +/ {
	italic()
	italic_mf()
	printf("<ul>\n")
	for (l=1; l<=NF; l++) {
		gsub(/^[\t ]*/,"",$l)
		if ($l ~ /\* +/) {
			match($l,"\\* +")
			str = substr($l,RSTART+RLENGTH)
			printf("\t<li>%s</li>\n", str)
		}
	}
	printf("</ul>\n")
	next
}

# End links
/^[\t ]*\[[0-9]/ {
	printf("<div id=endlinks>\n<ul>\n")
	for (u=1; u<=NF; u++) {
		gsub(/^[\t ]*/,"",$u)
		if (match($u,"\\[[0-9]+\\]")) {
			# RSTART can be replaced by 1, because we removed useless tabs/spaces
			num = substr($u,RSTART,RLENGTH)
			url = substr($u,RSTART+RLENGTH+1)
			if (length(url) >= 60) {
				printf("\t<li>%s <a href=\"%s\" target=\"_blank\">%.60s…</a></li>\n", num, url, url)
			} else {
				printf("\t<li>%s <a href=\"%s\" target=\"_blank\">%s</a></li>\n", num, url, url)
			}
		}
	}
	printf("</ul>\n</div>\n")
	next
}
