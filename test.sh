#!/bin/bash

PROGRAM='etapa6'
ILOCSIM='ilocsim.py'

RED='\033[0;31m'
GREEN='\033[0;32m' 
NO_COLOR='\033[0m'

clear

echo "Compiling..."
make clean
COMPILATION_LOG=$(make 2>&1)

COMPILATION_WARN=0

echo "$COMPILATION_LOG"

if echo $COMPILATION_LOG | grep -q ".y: warning"; then
    COMPILATION_WARN=1
    echo -ne $RED
    echo "WARNING: CHECK BISON COMPILATION"
    echo -ne $NO_COLOR
fi


echo -e "\nRunning tests..."
TESTS_PASSED=0
TOTAL_TESTS=0
for TEST_FILE in test/*_in.txt; do
    # build needed paths
    EXPECTED_FILE=${TEST_FILE//_in/_expected}
    DIFF_FILE=${TEST_FILE//_in/_diff}
    ILOC_FILE=${TEST_FILE//_in/_iloc}
    MEM_FILE=${TEST_FILE//_in/_mem}

    # run the tests
    $(./$PROGRAM < $TEST_FILE > $ILOC_FILE 2>&1)
    $(./$ILOCSIM -m $ILOC_FILE > $MEM_FILE 2>&1)
    $(diff -ws $MEM_FILE $EXPECTED_FILE > $DIFF_FILE)

    # inform test results
    if grep -q "are identical" $DIFF_FILE; then
        echo -ne $GREEN
        echo "TEST" \"$TEST_FILE\"": OK"
        echo -ne $NO_COLOR
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -ne $RED
        echo "TEST" \"$TEST_FILE\"": ERROR"
        echo -ne $NO_COLOR
        echo "Diff:"
        cat $DIFF_FILE
    fi

    echo -ne $NO_COLOR

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
done


echo -e "\nTests summary:"

if [[ $COMPILATION_WARN = 1 ]]; then
    echo -ne $RED
    echo "WARNING: CHECK BISON COMPILATION"
fi

if [[ $TESTS_PASSED = $TOTAL_TESTS ]]; then
    echo -ne $GREEN
else
    echo -ne $RED
fi

echo $TESTS_PASSED/$TOTAL_TESTS "TESTS PASSED"

echo -ne $NO_COLOR
