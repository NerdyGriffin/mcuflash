# bash completion for mcuflash
_mcuflash() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local commands="list boards klipper katapult config"
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands --help" -- "$cur"))
        return
    fi
    case "${COMP_WORDS[1]}" in
        klipper|katapult|config)
            if [[ $cur == -* ]]; then
                local flags="--board --config-dir --dry-run"
                [[ ${COMP_WORDS[1]} != config ]] && flags+=" --yes"
                [[ ${COMP_WORDS[1]} == katapult ]] && flags+=" --deployer"
                [[ ${COMP_WORDS[1]} == config ]] && flags+=" --katapult"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            elif [[ ${COMP_WORDS[COMP_CWORD-1]} == --board ]]; then
                COMPREPLY=($(compgen -W "$("${COMP_WORDS[0]}" boards 2>/dev/null | awk 'NR>1 {print $1}')" -- "$cur"))
            elif [[ ${COMP_WORDS[COMP_CWORD-1]} == --config-dir ]]; then
                COMPREPLY=($(compgen -d -- "$cur"))
            else
                COMPREPLY=($(compgen -W "$("${COMP_WORDS[0]}" complete-targets 2>/dev/null)" -- "$cur"))
            fi
            ;;
        list|boards)
            COMPREPLY=($(compgen -W "--config-dir --dry-run" -- "$cur"))
            ;;
    esac
}
complete -F _mcuflash mcuflash
