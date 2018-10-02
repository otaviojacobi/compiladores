#!/bin/bash

PROGRAM='etapa3'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
for TEST_FILE in $(ls test/*_in.txt | sort -V); do
    # build needed paths
    EXPECTED_FILE=$TEST_FILE
    DIFF_FILE=${TEST_FILE//_in/_diff}
    WARNING_DIFF_FILE=${TEST_FILE//_in/_warning_diff}
    OUT_FILE=${TEST_FILE//_in/_out}
    OUT_FILE2=${TEST_FILE//_in/_out2}
    VALGRIND_FILE=${TEST_FILE//_in/_valgrind}

    # run the tests
    $(./$PROGRAM < $TEST_FILE > $OUT_FILE 2>&1)
    $(./$PROGRAM < $OUT_FILE > $OUT_FILE2 2>&1)
    # $(echo RETURN CODE: $? >> $OUT_FILE)
    $(diff -wBEs $OUT_FILE $OUT_FILE2 > $DIFF_FILE)
    $(diff -wBEs $OUT_FILE $TEST_FILE > $WARNING_DIFF_FILE)
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

    # inform test results
    if [ "$(grep -c "are identical" $WARNING_DIFF_FILE)" -eq 0 ]; then
        echo -ne $YELLOW
        echo "WARNING: program output from "\"$TEST_FILE\"" differs from input file"
        echo -ne $NO_COLOR
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
