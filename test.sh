#!/bin/bash

PROGRAM='etapa4'

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

declare -A errors=(
    ["ERR_UNDECLARED"]=10
    ["ERR_DECLARED"]=11
    ["ERR_VARIABLE"]=20
    ["ERR_VECTOR"]=21
    ["ERR_FUNCTION"]=22
    ["ERR_USER"]=23
    ["ERR_WRONG_TYPE"]=30
    ["ERR_STRING_TO_X"]=31
    ["ERR_CHAR_TO_X"]=32
    ["ERR_USER_TO_X"]=33
    ["ERR_MISSING_ARGS"]=40
    ["ERR_EXCESS_ARGS"]=41
    ["ERR_WRONG_TYPE_ARGS"]=42
    ["ERR_WRONG_PAR_INPUT"]=50
    ["ERR_WRONG_PAR_OUTPUT"]=51
    ["ERR_WRONG_PAR_RETURN"]=52
)

echo -e "\nRunning tests..."
TESTS_PASSED=0
VALGRINDS_PASSED=0
TOTAL_TESTS=0
for TEST_FILE in $(ls test/); do
    # build needed paths
    result=$(cat test/$TEST_FILE | grep ERR_)
    ./$PROGRAM < test/$TEST_FILE > /dev/null
    PROGRAM_RESULT=$?
    if [ -z "$result" ]; then
        EXPECTED_RESULT=0
    else 
        result=${result:2}
        EXPECTED_RESULT="${errors[$result]}"
    fi

    if [ $PROGRAM_RESULT = $EXPECTED_RESULT ]; then
        echo -ne $GREEN
        echo "TEST" \"$TEST_FILE\"": OK"
        echo -ne $NO_COLOR
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -ne $RED
        echo "TEST" \"$TEST_FILE\"": ERROR"
        echo -ne $YELLOW
        echo "Was" \"$PROGRAM_RESULT\" "Should be:" \"$EXPECTED_RESULT\"
        echo -ne $NO_COLOR
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

echo -ne $NO_COLOR


# echo $VALGRINDS_PASSED/$TOTAL_TESTS "VALGRIND TESTS PASSED"

# echo -ne $NO_COLOR
