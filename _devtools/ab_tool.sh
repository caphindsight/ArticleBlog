#! /usr/bin/env bash

show_usage_and_exit() {
    echo "Usage: ab_tool <subcommand> [args]"
    echo "Available subcommands: load, clean"
    exit 1
}

if [ "$#" -eq 0 ]; then
    show_usage_and_exit
fi

if [ "$1" == "clean" ]; then
    shift 1

    if [ "$#" -ne 0 ]; then
        echo >&2 "Usage: lyxtool clean"
        exit 1
    fi

    echo "Cleaning *.html, *.json, *.pdf, index.jade, .gitignore, *~ .."
    rm -f *.html *.json *.pdf index.jade .gitignore *~

    echo "Done"

elif [ "$1" == "load" ]; then
    shift 1

    if [ "$#" -ne 2 ]; then
        echo >&2 "Usage: lyxtool load <name> <title>"
        exit 1
    fi

    NAME="$1"
    TITLE="$2"

    LYX_DOCUMENT="_${NAME}.lyx"

    if [ ! -f "$LYX_DOCUMENT" ]; then
        echo >&2 "LyX document '${LYX_DOCUMENT}' was not found!"
        exit 2
    fi

    PDF_OUTPUT="${NAME}.pdf"
    echo "Exporting to pdf.."
    if ! lyx -E pdf "$PDF_OUTPUT" "$LYX_DOCUMENT"; then
        echo >&2 "LyX: error while exporting to pdf"
        exit 3
    fi

    HTML_OUTPUT="${NAME}.html"
    echo "Exporting to html.."
    if ! elyxer --title "$TITLE" --css "/styles/lyx.css" --nofooter --mathjax remote "$LYX_DOCUMENT" "$HTML_OUTPUT"; then
        echo >&2 "LyX: (elyxer) error while exporting to html"
        exit 4
    fi

    echo "Generating index page.."
    (
        echo "extends /_templates/article.jade"
    ) >index.jade

    echo "Generating metadata.."
    (
        echo "{"
        echo "    \"name\"         : \"${NAME}\","
        echo "    \"title\"        : \"${TITLE}\","
        echo "    \"description\"  : \"\","
        echo "    \"draft\"        : true,"
        echo "    \"date\"         : \"$(date)\","
        echo "    \"timestamp\"    : \"$(date +%s)000\","
        echo "    \"pdf_url\"      : \"${PDF_OUTPUT}\","
        echo "    \"html_url\"     : \"${HTML_OUTPUT}\""
        echo "}"
    ) >_data.json

    echo "Generating .gitignore.."
    (
        echo "${PDF_OUTPUT}"
        echo "${HTML_OUTPUT}"
        echo "index.jade"
        echo "_data.json"
    ) >.gitignore

    echo "Done"

else show_usage_and_exit; fi

