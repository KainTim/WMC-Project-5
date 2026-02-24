#!/usr/bin/env bash
cd -- "$(dirname -- "$(readlink -f -- "$0")")" || exit 1
files_docs=(*.md)
files_protocols=(protocols/*.md)

files=("${files_docs[@]}" "${files_protocols[@]}")
[ -e "${files[0]}" ] || {
	echo "No files found"
	exit 1
}

for filename in "${files[@]}"; do
	name="${filename%%.*}"
	echo "$name"
	pandoc --pdf-engine=xelatex -V mainfont="DejaVu Serif" --output="build-pdf/$name.pdf" "$filename"
done
