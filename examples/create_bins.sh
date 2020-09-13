#! /bin/sh

##
# Helper script to create an executable for each example project to be placed in examples/bin dir
#
# Then these executables can be called directly without needing compilation in an Elixir/OTP env

APPS=(phoenix_app scenic_app simple_app simple_script)

EXAMPLES_DIR=$PWD

for app in "${APPS[@]}"
do
echo -e "*** Building $app bin ***"

cd $EXAMPLES_DIR/$app
rm -rf _build
mix release

echo -e "*** copying $app bin to examples/bin ***"
cp _build/prod/rel/bakeware/* $EXAMPLES_DIR/bin/

echo -e "*** Finished $app ****\n"
done
