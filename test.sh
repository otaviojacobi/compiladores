#!/bin/bash

#TODO: Added option to run with valgrind
RED='\033[0;31m'
GREEN='\033[0;32m' 
NO_COLOR='\033[0m'
echo "Running tests..."
for i in test/*.test; do
    cur_test=(${i//./ })
    expected_test="${cur_test[0]}"_expected.txt
    result="$(./etapa1 < $i | diff $expected_test - -w -b)"
    if [ "$result" = "" ];then
        echo -e "${GREEN}"${cur_test[0]}" passed${NO_COLOR}"
    else
        echo -e "${RED}"${cur_test[0]}" FAILED with error (check logs for more details):${NO_COLOR}"
        echo "$result" > "${cur_test[0]}".log
        head "${cur_test[0]}".log
    fi
done