#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${POSTGRES_USER:='odoo'}}
: ${PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}
: ${DB:=${POSTGRES_DB:='odoodb'}}
: ${WITHOUT_DEMO:=${WITHOUT_DEMO:='all'}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"
check_config "database" "$DB"

BASEDIR=$(dirname "$BASH_SOURCE")

echo "EntryPoint Called in $BASEDIR, case arg: $1: Setting up databse with config: $HOST, $PORT, $USER, $PASSWORD, $DB, DB_ARGS: ${DB_ARGS[@]}"

case "$1" in
    -- | /odoo/dist/odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            $BASEDIR/wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}" -i base --without-demo=${WITHOUT_DEMO} --load-language=en_GB
        fi
        ;;
    -*)
        $BASEDIR/wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}" -i base --without-demo=${WITHOUT_DEMO} --load-language=en_GB
        ;;
    *)
        exec "$@"
esac

sudo -u app sh -c "$@"

exit 1