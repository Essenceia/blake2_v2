set PROJ "emulator"

project open $PROJ.xise

project set "Other Compiler Options" "-define MISSING_CLOG2"
process run "Synthesize" -force rerun

process run "Translate" -force rerun
process run "Map" -force rerun
process run "Place & Route" -force rerun

process run "Generate Programming File" -force rerun

project close
