!/bin/bash

rm -rf ./unit_tests

# Comecemos por criar o diretorio de testes, onde criaremos diretorios e ficheiros, com nomes e tamanhos diferentes para
# testar todas as funcoes do nosso programa, desde a contabilização de espaço e capacidade de seleção de ficheiros até
# ordenamento do resultado.
mkdir ./unit_tests

# Seja create file uma função com parâmetros size, date e name
create_file() {
    truncate -s "$1" "./unit_tests/$3"                #   Criação de um ficheiro com tamanho predefinido
    touch -d "$2" "./unit_tests/$3"                   #   Alteração da data de última modificação
}

test_passed() {
    if [[ $? == 0 ]]; then
        echo "Test $1 passed!"
    else
        echo "Test $1 failed!"
    fi
}

create_file "14M" "Nov 1" "file1.a"
create_file "2" "Sep 10" "file\ with\ spaces.spacedout"
create_file "4M" "Dec 21" "file\ttabbed"
create_file "3M" "Nov 1" "under_scored"
create_file "1M" "Nov 1" "hyphened-file"
create_file "523M" "Nov 1" "a-script.c"
create_file "11M" "Nov 1" "having_extensions.sh"

mkdir ./unit_tests/directoryA
create_file "1M" "Nov 1" "directoryA/file1.a"
create_file "2K" "Sep 10" "directoryA/file\ with\ spaces.spacedout"
create_file "3M" "Dec 21" "directoryA/file\ttabbed"
create_file "16M" "Nov 1" "directoryA/under_scored"
create_file "1K" "Nov 1" "directoryA/hyphened-file"
create_file "53M" "Nov 1" "directoryA/a-script.c"
create_file "21M" "Nov 1" "directoryA/having_extensions.sh"

mkdir ./unit_tests/aaaaaaa
create_file "2M" "Sep 10" "aaaaaaa/file\ with\ spaces.spacedout"
create_file "30K" "Nov 1" "aaaaaaa/under_scored"
create_file "21K" "Nov 1" "aaaaaaa/hyphened-file"
create_file "523K" "Nov 1" "aaaaaaa/a-script.c"
create_file "210K" "Nov 1" "aaaaaaa/having_extensions.sh"

./spacecheck.sh "./unit_tests" | tail -n +2 | diff - ./expected_output/full.out > /dev/null 2>&1
test_passed 1
./spacecheck.sh -r "./unit_tests" |tail -n +2 | diff - ./expected_output/full_reversed.out > /dev/null 2>&1
test_passed 2
./spacecheck.sh -a "./unit_tests" |tail -n +2 | diff - ./expected_output/full_alphabetical.out > /dev/null 2>&1
test_passed 3
./spacecheck.sh -a -r -n ".*a.*" "./unit_tests" |tail -n +2 | diff - ./expected_output/contains_a_alphabetical_reversed.out > /dev/null 2>&1
test_passed 4
./spacecheck.sh -d "Sep 10" "./unit_tests" |tail -n +2 | diff - ./expected_output/older_than_sep10.out > /dev/null 2>&1
test_passed 5
./spacecheck.sh -s "4000000" "./unit_tests" |tail -n +2 | diff - ./expected_output/larger_than_4000000.out > /dev/null 2>&1
test_passed 6

rm -rf ./unit_tests
