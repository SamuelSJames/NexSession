#!/usr/bin/env bash

PY_FILE=XXX_PYCOMPLETION_XXX

nex_complete() {
    IFS=$'\n'
    COMPREPLY=($(compgen -W "$(python3 "$PY_FILE" "${COMP_WORDS[@]}")" -- "${COMP_WORDS[COMP_CWORD]}"))
    unset IFS
}

complete -F nex_complete nex_control
