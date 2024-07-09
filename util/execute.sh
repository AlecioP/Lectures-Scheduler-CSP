#!/bin/sh

MINIZINC_PATH="/Applications/MiniZincIDE.app/Contents/Resources/"

PATH=$PATH:$MINIZINC_PATH

minizinc ./Model.mzn "$1"
