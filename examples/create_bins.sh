#! /bin/sh

##
# Helper script to create an executable for each example project to be placed in examples/bin dir
#
# Then these executables can be called directly without needing compilation in an Elixir/OTP env

EXAMPLES_DIR=$PWD
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then 
  OS="MacOS"
fi;

for app in phoenix_app scenic_app simple_app simple_script
do
echo -e "*** Building $app bin ***"

cd $EXAMPLES_DIR/$app
rm -rf _build
mix release

echo -e "*** copying $app bin to examples/bin/$OS ***"
cp _build/prod/rel/bakeware/* $EXAMPLES_DIR/bin/$OS

echo -e "*** Finished $app ****\n"
done
