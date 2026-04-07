set shell := ["bash", "-cu"]

default:
    @just --list

build:
    ./scripts/build.sh

test:
    ./scripts/test.sh

doctor:
    ./scripts/doctor.sh

check:
    ./scripts/check.sh
