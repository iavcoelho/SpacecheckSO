#!/bin/bash

rm -rf ./unit_tests

# Comecemos por criar o diretorio de testes, onde criaremos diretorios e ficheiros, com nomes e tamanhos diferentes para
# testar todas as funcoes do nosso programa, desde a contabilização de espaço e capacidade de seleção de ficheiros até
# ordenamento do resultado.
mkdir ./unit_tests

passed_all_tests="0";

# Seja create file uma função com parâmetros size, date e name
create_file() {
    truncate -s "$1" "./unit_tests/$3"                #   Criação de um ficheiro com tamanho predefinido
    touch -d "$2" "./unit_tests/$3"                   #   Alteração da data de última modificação
}

test_passed() {
    passed_all_tests=$(($passed_all_tests + $?))
    if [[ $? == 0 ]]; then
        echo "Test $1 passed!"
    else
        echo "Test $1 failed!"
    fi
}

final_result() {
    if [[ $passed_all_tests == 0 ]]; then
        echo "All tests passed!"
    else
        echo "Tests failed!"
    fi
}

create_file "14124" "Nov 1" "file1.a"
create_file "323" "Sep 10" "file2.a"
create_file "341" "Nov 1" "under_scored-and-hyphened"
mkdir ./unit_tests/special_chars
create_file "3124" "2023-01-12" "special_chars/file\ with\ spaces"
create_file "2134" "2023-02-15" "special_chars/file\twith\ttabs"
create_file "3123" "2023-03-25" "special_chars/file\ with\ special\ characters\ \*\?\$"
create_file "1231" "2023-04-20" "special_chars/file\nwith\nnewlines"
create_file "235" "2023-05-17" "special_chars/--file"
create_file "1231" "2023-06-30" "special_chars/file\ with\ globbing\ characters\ *\?\[\]"
create_file "312" "2023-07-07" "special_chars/file\ with\ control\ characters\ \0\007"
create_file "32" "2023-08-24" "special_chars/file\ with\ non-printable\ characters\ \x01\x02\x03"
mkdir ./unit_tests/permissionless
mkdir ./unit_tests/permissionless/unaccessable_dir
chmod -rwx ./unit_tests/permissionless/unaccessable_dir
create_file "14124" "Nov 1" "permissionless/file1.a"
create_file "323" "Oct 13" "permissionless/file2.a"
create_file "341" "Nov 1" "permissionless/under_scored-and-hyphened"
chmod -rwx ./unit_tests/permissionless/*

mkdir ./unit_tests/regex_tests
create_file "10" "Nov 10" "regex_tests/abcMADsdas"
create_file "10" "Nov 10" "regex_tests/jsDNAJabc"
create_file "10" "Nov 10" "regex_tests/acbjajd"
create_file "10" "Nov 10" "regex_tests/.a"
create_file "10" "Nov 10" "regex_tests/1234"
create_file "10" "Nov 10" "regex_tests/ASKO"
create_file "10" "Nov 10" "regex_tests/onlylower"
create_file "10" "Nov 10" "regex_tests/ONLYUPPER"
create_file "10" "Nov 10" "regex_tests/lll"
create_file "10" "Nov 10" "regex_tests/file1.a"

mkdir ./unit_tests/date_tests
create_file "10" "Nov 10" "date_tests/a"
create_file "10" "Oct 31" "date_tests/b"
create_file "10" "Sep 12" "date_tests/c"
create_file "10" "Aug 02" "date_tests/d"

mkdir ./unit_tests/size_tests
create_file "10" "Nov 10" "size_tests/a"
create_file "100" "Nov 10" "size_tests/b"
create_file "200" "Nov 10" "size_tests/c"
create_file "300" "Nov 10" "size_tests/d"
create_file "400" "Nov 10" "size_tests/e"

# Run the tests
faketime "Nov 13" ./spacecheck.sh "./unit_tests" | diff -"./expected_output/full.out"
test_passed "General 1"
faketime "Nov 13" ./spacecheck.sh -r "./unit_tests" | diff -"./expected_output/full_reversed.out"
test_passed "General 2"
faketime "Nov 13" ./spacecheck.sh -a "./unit_tests" | diff -"./expected_output/full_alphabetical.out"
test_passed "General 3"
faketime "Nov 13" ./spacecheck.sh -ar "./unit_tests" | diff -"./expected_output/full_alphabetical_reverse.out"
test_passed "General 4"
faketime "Nov 13" ./spacecheck.sh -l 1 "./unit_tests" | diff -"./expected_output/oneline.out"
test_passed "General 5"

# Regex Tests
faketime "Nov 13" ./spacecheck.sh -n "abc.*" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/1.out"
test_passed "Regex 1"
faketime "Nov 13" ./spacecheck.sh -n ".*abc" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/2.out"
test_passed "Regex 2"
faketime "Nov 13" ./spacecheck.sh -n ".*a.b.*" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/3.out"
test_passed "Regex 3"
faketime "Nov 13" ./spacecheck.sh -n ".*a+.*" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/4.out"
test_passed "Regex 4"
faketime "Nov 13" ./spacecheck.sh -n "[abc]" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/5.out"
test_passed "Regex 5"
faketime "Nov 13" ./spacecheck.sh -n "[^abc]" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/6.out"
test_passed "Regex 6"
faketime "Nov 13" ./spacecheck.sh -n "[a-z]" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/7.out"
test_passed "Regex 7"
faketime "Nov 13" ./spacecheck.sh -n "[A-Z]" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/8.out"
test_passed "Regex 8"
faketime "Nov 13" ./spacecheck.sh -n "[0-9]" "./unit_tests/regex_tests" | diff -"./expected_output/regex_tests/9.out"
test_passed "Regex 9"

# Size Tests
faketime "Nov 13" ./spacecheck.sh -s "10" "./unit_tests/size_tests" | diff -"./expected_output/size_tests/1.out"
test_passed "Size 1"
faketime "Nov 13" ./spacecheck.sh -s "100" "./unit_tests/size_tests" | diff -"./expected_output/size_tests/2.out"
test_passed "Size 2"
faketime "Nov 13" ./spacecheck.sh -s "200" "./unit_tests/size_tests" | diff -"./expected_output/size_tests/3.out"
test_passed "Size 3"
faketime "Nov 13" ./spacecheck.sh -s "300" "./unit_tests/size_tests" | diff -"./expected_output/size_tests/4.out"
test_passed "Size 4"

# Date Tests
faketime "Nov 13" ./spacecheck.sh -d "n" "./unit_tests/date_tests" | diff -"./expected_output/date_tests/1.out"
test_passed "Date 1"
faketime "Nov 13" ./spacecheck.sh -d "Nov 1" "./unit_tests/date_tests" | diff -"./expected_output/date_tests/2.out"
test_passed "Date 2"
faketime "Nov 13" ./spacecheck.sh -d "01/10/2023" "./unit_tests/date_tests" | diff -"./expected_output/date_tests/3.out"
test_passed "Date 3"
faketime "Nov 13" ./spacecheck.sh -d "2023/8/01" "./unit_tests/date_tests" | diff -"./expected_output/date_tests/4.out"
test_passed "Date 4"

# Forced Errors
faketime "Nov 13" ./spacecheck.sh -d "./unit_tests/date_tests" | diff -"./expected_output/errors/1.out"
test_passed "Error 1"
faketime "Nov 13" ./spacecheck.sh -d "asdas" "./unit_tests/date_tests" | diff -"./expected_output/errors/2.out"
test_passed "Error 2"
faketime "Nov 13" ./spacecheck.sh -s "./unit_tests/date_tests" | diff -"./expected_output/errors/3.out"
test_passed "Error 3"
faketime "Nov 13" ./spacecheck.sh -s "aa" "./unit_tests/date_tests" | diff -"./expected_output/errors/4.out"
test_passed "Error 4"
faketime "Nov 13" ./spacecheck.sh -n "./unit_tests/date_tests" | diff -"./expected_output/errors/5.out"
test_passed "Error 5"
faketime "Nov 13" ./spacecheck.sh  | diff -"./expected_output/errors/6.out"
test_passed "Error 6"

# Show final result
final_result

# Clean the testing directory
# rm -rf ./unit_tests
