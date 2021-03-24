#!/bin/bash
# flatbuffers generation buildfile

set -eu

tempdir=build/tmp

onexit()
{
    # Remove temporary directory on exit.
    rm -rf "$tempdir"
}

rm -rf build/ 
mkdir -p "$tempdir"
trap onexit INT EXIT


generate()
{
    local lang=$1
    local ns=$2
    local opts="${@:3}"

    if [[ "$ns" = "" ]]; then
        
        cp flatbuffers/*.fbs "$tempdir/"
    else
        # @exports language-specific namespace 
        for f in flatbuffers/*.fbs; do
            sed "s|// {{namespace}}|namespace $ns;|" "$f" >"$tempdir/${f##*/}"
        done
    fi
    flatc "--$lang" "$opts" -o "build/$lang" "$tempdir/"*.fbs
}

generate go maidenlane
generate java com.manifoldfinance.maidenlane
generate ts maidenlane --short-names --no-fb-import
echo "Generation Successful"
