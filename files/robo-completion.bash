#!/bin/sh
function __robo_list_cmds ()
{
      robo list --raw | awk '{print $1}' | sort
}

function __robo_list_opts ()
{
    robo list --no-ansi | sed -e '1,/Options:/d' -e '/^$/,$d' -e 's/^ *//' -e 's/ .*//' | sort
}

_robo()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$(__robo_list_opts) $(__robo_list_cmds)" -- ${cur}))
    return 0;
}

complete -o default -F _robo robo
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
