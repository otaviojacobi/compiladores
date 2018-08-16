#!/bin/bash

for i in test/*.test.c; do
    echo "${i}"
    cur_test=(${i//./ })
    expected_test="${cur_test[0]}"_expected.c
    echo "$expected_test"
    ./etapa1 < "$i" | diff "$expected_test" - -w -b
done