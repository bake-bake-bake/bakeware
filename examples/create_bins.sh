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

BIN_DIR=$EXAMPLES_DIR/bin/$OS

mkdir -p $BIN_DIR

for app in phoenix_app scenic_app simple_app simple_script iex_prompt nif_script
do
echo "*** Building $app bin ***"

cd $EXAMPLES_DIR/$app
rm -rf _build
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix setup
MIX_ENV=prod mix release

echo "*** copying $app bin to examples/bin/$OS ***\n"
cp _build/prod/rel/bakeware/* $BIN_DIR

echo "*** Finished $app ****\n"
done
