#!/usr/bin/env bash
set -e


for cred in "-v3 -u usr-none-none -l noAuthNoPriv demo-snmp.thola.io" \
            "-v3 -u usr-md5-none -l authNoPriv -A authkey1 demo-snmp.thola.io" \
            "-v3 -u usr-sha-aes -a SHA -x AES -l authPriv -A authkey1 -X privkey1 demo-snmp.thola.io" \
            "-v3 -u usr-md5-aes -x AES -l authPriv -A authkey1 -X privkey1 demo-snmp.thola.io" \
            "-v3 -u usr-sha-des -a SHA -l authPriv -A authkey1 -X privkey1 demo-snmp.thola.io" \
            "-v3 -u usr-sha-aes256 -a SHA -x AES256 -l authPriv -A authkey1 -X privkey1 demo-snmp.thola.io" \
            "-v2c -c public demo-snmp.thola.io" \
            "-v1 -c public demo-snmp.thola.io"
do
    for x in snmpget.py \
             snmpwalk.py \
             snmpbulkwalk.py
    do
        COMMAND="python scripts/${x} ${cred} sysDescr.0"
        echo $COMMAND
        eval $COMMAND
        COMMAND="python scripts/${x} ${cred} system"
        echo $COMMAND
        eval $COMMAND
    done
    for x in snmpset.py
    do
        COMMAND="python scripts/${x} ${cred} sysORDescr.0 = $(hostname)"
        echo $COMMAND
        eval $COMMAND
    done
    for x in snmptrap.py
    do
        case "${cred}"
        in
        *-v1*)
            COMMAND="python scripts/${x} ${cred} 1.3.6.1.4.1.20408.4.1.1.2 127.0.0.1 warmStart 432 12345 1.3.6.1.2.1.1.1.0 s $(hostname)"
            echo $COMMAND
            eval $COMMAND
            ;;
        *)
            COMMAND="python scripts/${x} ${cred} 0 1.3.6.1.6.3.1.1.5.1 1.3.6.1.2.1.2.2.1.1.123 i 123 1.3.6.1.2.1.2.2.1.7.123 i 1 1.3.6.1.2.1.2.2.1.8.123 i 1"
            echo $COMMAND
            eval $COMMAND
            COMMAND="python scripts/${x} -Ci ${cred} 0 1.3.6.1.6.3.1.1.5.1 1.3.6.1.2.1.2.2.1.1.123 i 321 1.3.6.1.2.1.2.2.1.7.123 i 2 1.3.6.1.2.1.2.2.1.8.123 i 2"
            echo $COMMAND
            eval $COMMAND
        esac
    done
done

COMMAND="python scripts/snmptranslate.py IF-MIB::linkUp"
echo $COMMAND
eval $COMMAND
