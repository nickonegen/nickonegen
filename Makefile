OUT = README.md
SRC = src/README.md

IMG_LANGS_MANIFEST = src/images/raw/langbadges/\#
IMG_LANGS = src/images/langs.png

all:
	#
	# "Transpile" components from pandoc markdown to github-flavored markdown
	#
	cp ${SRC} ${SRC}.bak
	pandoc --fail-if-warnings -f markdown -t gfm -o ./src/PROJECTS-gfm.md ./src/PROJECTS.md
	#
	# Insert components into README.md
	#
	gawk -i inplace \
		'BEGIN { \
			RS="@"; \
			getline l < "src/PROJECTS-gfm.md"; \
			RS="\n" \
		}/{::insert PROJECTS.md}/{ \
			gsub("{::insert PROJECTS.md}", l) \
		}1' ${SRC}
	#
	# "Transpile" README.md into HTML
	#
	kramdown -i kramdown -o html ${SRC} \
		| sed 's/&gt;/>/g' \
		| sed 's/&lt;/</g' > ${OUT}
	#
	# Remove components and temporary files, restore original README.md
	#
	rm ./src/PROJECTS-gfm.md
	mv ${SRC}.bak ${SRC}

img:
	# Generate image of language badges
	#
	montage -mode concatenate -tile x1 -geometry 80x80\+10+0 -background transparent \
		`cat -s ${IMG_LANGS_MANIFEST} \
		| sed 's/^/src\/images\/raw\/langbadges\//'` miff:- \
		| convert - -trim ${IMG_LANGS}

clean:
	rm ${OUT}
	rm ${IMG_LANGS}
