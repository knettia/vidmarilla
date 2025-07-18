
TEX_FILE := road-to-1.0.tex
OUT_DIR := out

.PHONY: all clean

all:
	latexmk -pdf -output-directory=$(OUT_DIR) $(TEX_FILE)

clean:
	latexmk -C -output-directory=$(OUT_DIR)
