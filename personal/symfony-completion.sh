#!bash
#
# bash completion support for symfony2 console
#
# Copyright (C) 2011 Matthieu Bontemps <matthieu@knplabs.com>
# Distributed under the GNU General Public License, version 2.0.

_symfony_console()
{
    local cur prev opts cmd
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd="${COMP_WORDS[0]}"
    PHP='
        $ret = shell_exec($argv[1]);

        $ret = preg_replace("/^.*Available commands:\n/s", "", $ret);
        $ret = explode("\n", $ret);

        $comps = array();
        foreach ($ret as $line) {
            if (preg_match("@^  ([^ ]+) @", $line, $m)) {
                $comps[] = $m[1];
            }
        }

        echo implode("\n", $comps);
'
    possible=$(php -r "$PHP" $COMP_WORDS);
    COMPREPLY=( $(compgen -W "${possible}" -- ${cur}) )
    return 0
}

complete -F _symfony_console console
complete -F _symfony_console console-dev
complete -F _symfony_console console-test
complete -F _symfony_console console-prod
complete -F _symfony_console console-staging
complete -F _symfony_console Symfony
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
