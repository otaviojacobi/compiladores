#!/bin/bash

PROGRAM='etapa2'

RED='\033[0;31m'
GREEN='\033[0;32m' 
NO_COLOR='\033[0m'

clear

echo "Compiling..."
make clean
COMPILATION_LOG="$(make 2>&1)"

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
VALGRINDS_PASSED=0
TOTAL_TESTS=0
for TEST_FILE in test/*_in.txt; do
    # build needed paths
    EXPECTED_FILE=${TEST_FILE//_in/_expected}
    DIFF_FILE=${TEST_FILE//_in/_diff}
    OUT_FILE=${TEST_FILE//_in/_out}
    VALGRIND_FILE=${TEST_FILE//_in/_valgrind}

    # run the tests
    $(./$PROGRAM < $TEST_FILE > $OUT_FILE 2>&1)
    $(echo RETURN CODE: $? >> $OUT_FILE)
    $(diff -ws $OUT_FILE $EXPECTED_FILE > $DIFF_FILE)
    $(valgrind --leak-check=full ./$PROGRAM < $TEST_FILE > $VALGRIND_FILE 2>&1)

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

    # inform Valgrind test results
    if grep -q "ERROR SUMMARY: 0 errors from 0 contexts" $VALGRIND_FILE; then
        echo -ne $GREEN
        echo "VALGRIND FOR" \"$TEST_FILE\"": OK"
        VALGRINDS_PASSED=$((VALGRINDS_PASSED + 1))
    else
        echo -ne $RED
        echo "VALGRIND FOR" \"$TEST_FILE\"": ERROR -- CHECK LOG"
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

if [[ $VALGRINDS_PASSED = $TOTAL_TESTS ]]; then
    echo -ne $GREEN
else
    echo -ne $RED
fi

echo $VALGRINDS_PASSED/$TOTAL_TESTS "VALGRIND TESTS PASSED"

echo -ne $NO_COLOR
