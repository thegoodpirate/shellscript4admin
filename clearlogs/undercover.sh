#!/usr/bin/env bash

LOGS_FILES=(
        /var/log/messages # General message and system related stuff
        /var/log/auth.log # Authenication logs
        /var/log/kern.log # Kernel logs
        /var/log/cron.log # Crond logs
        /var/log/maillog # Mail server logs
        /var/log/boot.log # System boot log
        /var/log/mysqld.log # MySQL database server log file
        /var/log/qmail # Qmail log directory
        /var/log/httpd # Apache access and error logs directory
        /var/log/lighttpd # Lighttpd access and error logs directory
        /var/log/secure # Authentication log
        /var/log/utmp # Login records file
        /var/log/wtmp # Login records file
        /var/log/lastlog # Login records file        
        /var/log/yum.log # Yum command log file
        /var/log/system.log # System Log
        /var/log/DiagnosticMessages # Mac Analytics Data
        /Library/Logs # System Application Logs
        /Library/Logs/DiagnosticReports # System Reports
        ~/Library/Logs # User Application Logs
        ~/Library/Logs/DiagnosticReports # User Reports
)

function isRoot () {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

function menu () {
        echo
        echo "undercover"
        echo
        echo "Escolha uma opcao"
        echo
        echo "1) Limpar o rasto do utilizador $USER"
        echo "2) Desativar auth & bash history"
        echo "3) Restaurar default"
        echo "99) Sair"
        echo

        printf "> "
        read -r option
        echo
}

function disableAuth () {
        if [ -w /var/log/auth.log ]; then
                ln /dev/null /var/log/auth.log -sf
                echo "[+] Substituir /var/log/auth.log por /dev/null"
        else
                echo "[!] /var/log/auth.log acesso nao autorizado! Tente novamente."
        fi
}

function disableHistory () {
        ln /dev/null ~/.bash_history -sf
        echo "[+] Substituir bash_history por /dev/null"

        if [ -f ~/.zsh_history ]; then
                ln /dev/null ~/.zsh_history -sf
                echo "[+] Substituir zsh_history por /dev/null"
        fi

        export HISTFILESIZE=0
        export HISTSIZE=0
        echo "[+] Colocar HISTFILESIZE & HISTSIZE a 0"

        set +o history
        echo "[+] Desativar history"

        echo
        echo "Desativar bash log."
}

function enableAuth () {
        if [ -w /var/log/auth.log ] && [ -L /var/log/auth.log ]; then
                rm -rf /var/log/auth.log
                echo "" > /var/log/auth.log
                echo "[+] Desativar substituicao de auth logs por /dev/null"
        else
                echo "[!] /var/log/auth.log acesso nao autorizado! Tente novamente."
        fi
}

function enableHistory () {
        if [[ -L ~/.bash_history ]]; then
                rm -rf ~/.bash_history
                echo "" > ~/.bash_history
                echo "[+] Desativar substituicao de history por /dev/null"
        fi

        if [[ -L ~/.zsh_history ]]; then
                rm -rf ~/.zsh_history
                echo "" > ~/.zsh_history
                echo "[+] Desativar substituicao de zsh history por /dev/null"
        fi

        export HISTFILESIZE=""
        export HISTSIZE=50000
        echo "[+] Restaurar HISTFILESIZE & HISTSIZE."

        set -o history
        echo "[+] Ativar history"

        echo
        echo "Ativar bash log."
}

function clearLogs () {
        for i in "${LOGS_FILES[@]}"
        do
                if [ -f "$i" ]; then
                        if [ -w "$i" ]; then
                                echo "" > "$i"
                                echo "[+] $i limpo."
                        else
                                echo "[!] $i nao autorizado! Tente novamente."
                        fi
                elif [ -d "$i" ]; then
                        if [ -w "$i" ]; then
                                rm -rf "${i:?}"/*
                                echo "[+] $i limpo."
                        else
                                echo "[!] $i nao autorizado! Tente novamente."
                        fi
                fi
        done
}

function clearHistory () {
        if [ -f ~/.zsh_history ]; then
                echo "" > ~/.zsh_history
                echo "[+] ~/.zsh_history limpo."
        fi

        echo "" > ~/.bash_history
        echo "[+] ~/.bash_history limpo."

        history -c
        echo "[+] History limpo."

        echo
        echo "As alterações terao efeito ao fazer logout."

}

function exitTool () {
        exit 1
}

clear # Clear output

# "now" option
if [ -n "$1" ] && [ "$1" == 'now' ]; then
        clearLogs
        clearHistory
        exit 0
fi

menu

if [[ $option == 1 ]]; then
        # Clear logs & current history
        clearLogs
        clearHistory
elif [[ $option == 2 ]]; then
        # Permenently disable auth & bash log
        disableAuth
        disableHistory
elif [[ $option == 3 ]]; then
        # Restore default settings
        enableAuth
        enableHistory
elif [[ $option == 99 ]]; then
        # Exit tool
        exitTool
else
        echo "[!] Opcao incorreta."
fi
