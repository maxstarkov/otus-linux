#!/bin/sh

# Путь к репозиторию бекапа.
export BORG_REPO=ssh://vagrant@192.168.11.101/var/backup

# Пароль для доступа к репозиторию.
export BORG_PASSPHRASE='123'

# Отключение верификации ssh ключей.
export BORG_RSH='ssh -o StrictHostKeyChecking=no'

# Вспомогательные методы и отработка сигналов.
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Запуск бекапа каталога /etc

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
                                    \
    ::'{hostname}-{now}'            \
    /etc                            \
    
backup_exit=$?

info "Pruning repository"

# Хранение ежедневных архивов в течение 90 дней и ежемесячных архивов в течение 12 месяцев.

borg prune                          \
    --list                          \
    --prefix '{hostname}-'          \
    --show-rc                       \
    --keep-daily    90              \
    --keep-monthly  12              \
                                    \
    ::

prune_exit=$?

# Определение общего результата выполнения команд архивирования и очистки.
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
