#!/bin/bash

repoRoot="$( git rev-parse --show-toplevel )"

rootCommit="$( git merge-base origin/master HEAD )"

changedFiles="$( git diff --name-only --diff-filter=ACMRTUXB "$rootCommit" | sort )"

echo "Files:"
echo "$changedFiles" | sed 's/^/  /'

runFixer() {
    vendor/bin/php-cs-fixer "$@" 2>&1 \
        | grep -vE '^Using cache file' \
        | grep -vE '^Loaded config default' \
        | grep -vE '^Fixed all files in ' \
        | grep -vE '^Legend: .-unknown, ' \
        | sed -e '/^$/d' -e "s|$repoRoot/||"
}

echo "Running php-cs-fixer for .php"
runFixer fix -v --config=.php_cs.dist --path-mode=intersection "$@" $changedFiles

echo "Running php-cs-fixer for .phtml"
runFixer fix -v --config=.phtml_cs.dist --path-mode=intersection "$@" $changedFiles
