#!/bin/bash

. .setup_env

cd $ZKSYNC_HOME

IN_DIR=./contracts/contracts
OUT_DIR=./contracts/contracts/generated

rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cp $IN_DIR/Governance.sol $OUT_DIR/GovernanceTest.sol
cp $IN_DIR/Verifier.sol $OUT_DIR/VerifierTest.sol
cp $IN_DIR/Franklin.sol $OUT_DIR/FranklinTest.sol
cp $IN_DIR/Storage.sol $OUT_DIR/StorageTest.sol
cp $IN_DIR/Config.sol $OUT_DIR/ConfigTest.sol
cp $IN_DIR/UpgradeModule.sol $OUT_DIR/UpgradeModuleTest.sol
cp $IN_DIR/Bytes.sol $OUT_DIR/Bytes.sol
cp $IN_DIR/Events.sol $OUT_DIR/Events.sol
cp $IN_DIR/Operations.sol $OUT_DIR/Operations.sol
cp $IN_DIR/VerificationKey.sol $OUT_DIR/VerificationKey.sol

# Change dependencies
ssed 's/import "\.\./import "\.\.\/\.\./' -i $OUT_DIR/*.sol
# Rename contracts
ssed 's/Governance/GovernanceTest/' -i $OUT_DIR/*.sol
ssed 's/Verifier/VerifierTest/' -i $OUT_DIR/*.sol
ssed 's/Franklin/FranklinTest/' -i $OUT_DIR/*.sol
ssed 's/Storage/StorageTest/' -i $OUT_DIR/*.sol
ssed 's/Config/ConfigTest/' -i $OUT_DIR/*.sol
ssed 's/UpgradeModule/UpgradeModuleTest/' -i $OUT_DIR/*.sol


# Changes solidity constant to provided value
# In solidity constant should be in the following form.
# $SOME_TYPE constant $NAME = $VALUE;
set_constant() {
	ssed -E "s/(.*constant $1)(.*)\;/\1 = $2\;/" -i $3
}
create_constant_getter() {
	ssed -E "s/    (.*) (constant $1)(.*)\;(.*)/    \1 \2\3\;\4\n    function get_$1() external pure returns (\1) {\n        return $1\;\n    }/" -i $2
}

# Change constants
set_constant MAX_AMOUNT_OF_REGISTERED_TOKENS 4 $OUT_DIR/ConfigTest.sol
set_constant EXPECT_VERIFICATION_IN 8 $OUT_DIR/ConfigTest.sol
set_constant MAX_UNVERIFIED_BLOCKS 4 $OUT_DIR/ConfigTest.sol
set_constant PRIORITY_EXPIRATION 16 $OUT_DIR/ConfigTest.sol
set_constant WAIT_UPGRADE_MODE_PERIOD 4 $OUT_DIR/UpgradeModuleTest.sol

create_constant_getter MAX_AMOUNT_OF_REGISTERED_TOKENS $OUT_DIR/ConfigTest.sol
create_constant_getter WAIT_UPGRADE_MODE_PERIOD $OUT_DIR/UpgradeModuleTest.sol

# Verify always true
set_constant DUMMY_VERIFIER true $OUT_DIR/VerifierTest.sol
