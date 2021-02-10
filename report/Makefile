all: report.pdf

report.pdf: report.md bibliography.bib
	pandoc --csl=ieee.csl report.md \
	       --biblio=bibliography.bib \
	       -F pandoc-crossref \
	       --number-sections --citeproc \
	       -o report.pdf


clean:
	rm report.aux report.tex report.log report.bbl report.blg report.out

open: report.pdf
	open $<

.PHONY: all clean paper
