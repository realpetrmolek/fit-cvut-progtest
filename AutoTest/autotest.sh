#!/bin/bash

FUZZ_COUNT=100

BASEDIR=$(dirname "$0")

RADAMSA_GIT="https://gitlab.com/akihe/radamsa.git"
RADAMSA_BIN="${BASEDIR}/radamsa/bin/radamsa"

#rm log.log
#exec 3>&1 1>>log.log 2>&1

function header(){
    clear
    echo "
ČVUT           _     _______        _
    /\        | |   |__   __|      | |  
   /  \  _   _| |_ ___ | | ___  ___| |_ 
  / /\ \| | | | __/ _ \| |/ _ \/ __| __|
 / ____ \ |_| | || (_) | |  __/\__ \ |_ 
/_/    \_\__,_|\__\___/|_|\___||___/\__|
                        v1 by Petr Molek

"
}

function dependencyCheck() {
    if [[ ! -f "$RADAMSA_BIN" ]]; then      # Is RADAMSA downloaded?
        command -v make > /dev/null
        if [[ "${?}" -ne 0 ]]; then         # Is MAKE installed?
            sudo apt-get install make -y
        fi
        git clone $RADAMSA_GIT 
        (cd radamsa && make)
    fi
}

echo "Installing dependencies..."
dependencyCheck

mkdir autotest > /dev/null

header
read -e -p "Source code: " sourcecode
read -e -p "Sample data: " sampledata

printf "\n\n"

# Compile
echo "[AutoTest] Compiling..."
if ! g++ -std=c++14 -Wall -pedantic -Wno-long-long -O2 -c -o autotest/program.out $sourcecode; then
    echo "[AutoTest] COMPILER ERROR/WARNING"
    exit 1
fi
gcc -Wall -pedantic -g -o autotest/program.out $sourcecode
echo "[AutoTest] Compilation successfull!"

# Sample data
echo "[AutoTest] Trying sample data..."
rm -r autotest/CZE &> /dev/null
(cd autotest && tar -zxf $sampledata CZE)
total=0
failed=0
for filename in autotest/CZE/*_in.txt; do
    ((total++))
    ./autotest/program.out < $filename > autotest/out.txt
    if ! diff "autotest/out.txt" "${filename/'in'/'out'}"; then
        echo "[AutoTest] $filename produced different result than expected."
        ((failed++))
    fi
done
((failed=total-failed))
echo "[AutoTest] ($failed/$total) samples produced expected results."

# Radamsa
echo "[AutoTest] Trying random data..."
total=0
failed=0
for filename in autotest/CZE/*_in.txt; do
    count=$FUZZ_COUNT
    while [ $count != 0 ]; do
        ((total++))
        radamsa=`$RADAMSA_BIN < $filename | tr -d '\0'`
        echo $radamsa | ./autotest/program.out > /dev/null
        error=${?}
        if [[ $error > 128 ]]; then
            ((failed++))
            echo "[AutoTest] Program crashed with error code ($error)! Input: ($radamsa)"
        fi
        ((count--))
    done
done
echo "[AutoTest] Program crashed in ($failed/$total) tests."
