#!/bin/bash
log="/var/log/monitor_sistema.log"
intervalo=5
while true
do
    tiempo=$(date "+%Y-%m-%d %H:%M:%S")
    datos=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6) ##consigue los datos de los 5 procesos con mayor consumo de CPU
    echo "$tiempo" >> $log
    echo "$datos" >> $log
    echo "" >> $log
    # Esperar el intervalo (PDF Shell_Scripting, comando sleep)
    sleep $intervalo
done
