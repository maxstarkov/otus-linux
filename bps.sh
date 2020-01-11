PROGNAME=$(basename $0)

print_result() {
        ticks=$(getconf CLK_TCK)
        screen_cols=$(tput cols)
        pids=$(find /proc -mindepth 1 -maxdepth 1 -name '[[:digit:]]*' -type d -exec basename '{}' ';')
        printf "%s\t%s\t%s\t%s\t%s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"
        for pid in $pids
        do
                if [[ ! -r /proc/$pid/stat ]]
                then
                        continue
                fi

                pid_stat=($(cat /proc/$pid/stat))
                cmd_line=$(cat /proc/$pid/cmdline)

                if [[ $cmd_line ]]
                then
                        proc_command=$cmd_line
                else
                        proc_command=${pid_stat[1]}
                fi

                proc_pid=${pid_stat[0]}

                dec_major_minor=${pid_stat[6]}

                major=$(( ($dec_major_minor >> 8) & (1 << 8) -1 ))
                minor_f=$(( ($dec_major_minor >> 20) & (1 << 11) -1 ))
                minor_s=$(( ($dec_major_minor >> 0) & (1 << 8) -1 ))
                major_minor=$major:$(( $minor_f + $minor_s))

                proc_status=${pid_stat[2]}

                proc_time=$(( (${pid_stat[13]} + ${pid_stat[14]}) / $ticks ))
                proc_time_sec=$(( proc_time % 60 ))
                proc_time_min=$(( proc_time/60 % 60 ))

                printf "%d\t%s\t%s\t%d:%02d\t%.$(($screen_cols - 50))s\n" $proc_pid $major_minor $proc_status $proc_time_min $proc_time_sec "$proc_command"
        done
}

usage() {

        echo "This bash script emulated ps ax command. $PROGNAME: usage $PROGNAME [-h|--help]"
        return

}

main() {

        while [[ -n $1 ]]
        do
                case $1 in
                        -h | --help)    usage
                                        exit
                                        ;;
                        *)              usage >&2
                                        exit
                                        ;;
                esac
        done

        print_result

}

main $1
