# This file should be SOURCED, not executed!
# . /path/to/activate.sh

ABSPATH=$(dirname $(readlink -f $BASH_SOURCE))
export LD_LIBRARY_PATH=$ABSPATH/.local/lib/ 
module load system/fx700 
module load FJSVstclanga/1.1.0
. $ABSPATH/fccbuild_v150/bin/activate

