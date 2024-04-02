#!/usr/bin/env bash

set -o errexit
set -o nounset
ROOT=$PWD
SIMD="go run ./simd/main.go"

cd simapp
$SIMD init aurn-node --chain-id aurn-chain

cd ~/.simapp/config

# to enable the api server
sed -i '.bak' '/\[api\]/,+3 s/enable = false/enable = true/' app.toml

# to change the voting_period
jq '.app_state.gov.voting_params.voting_period = "600s"' genesis.json > temp.json && mv temp.json genesis.json

# to change the inflation
jq '.app_state.mint.minter.inflation = "0.300000000000000000"' genesis.json > temp.json && mv temp.json genesis.json

cd "$ROOT"/simapp
$SIMD keys add test_validator --keyring-backend test
VALIDATOR_ADDRESS=$($SIMD keys show test_validator -a --keyring-backend test)

$SIMD genesis add-genesis-account "$VALIDATOR_ADDRESS" 1000000000stake
$SIMD genesis gentx test_validator 1000000000stake --keyring-backend test
$SIMD genesis collect-gentxs