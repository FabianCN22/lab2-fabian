#!/bin/bash

comando=$1
intervalo=$2

if [ $# -eq 0 ]; then ##verifica que se reciba el comando a ejecutar y el intervalo
  echo "Uso: $0 \"comando\" intervalo"
  exit 1
fi

##se usa '&' para ejecutar el comando en background
$comando &
PID=$! ##esto contiene el PID del ultimo proceso que se ejecuto en BG


log="monitor_${PID}.log"
png="monitor_${PID}.png"

echo "el PID del proceso monitoreado es: $PID"
echo "log se guardo en: $log"

capturar_interrupcion() {
  echo ""
  echo "se a usado Ctrl+C. enviando SIGTERM al proceso de PID: $PID"

  kill $PID ##sqe killea el proceso
  sleep 1
}
trap capturar_interrupcion SIGINT

segundos=0 ##contador para la grafica

while kill -0 $PID 2> /dev/null ##mientras el proceso exista que se verificar con "kill -0" y cilco continua
do
  fecha=$(date "+%Y-%m-%d %H:%M:%S")
  ##sugerencia para el lab:  ps -p PID -o %cpu,%mem,rss --no-headers
  datos=$(ps -p $PID -o %cpu,%mem,rss --no-headers) ##guardanos los datos del cpu ram, etc

  echo "$fecha $datos $segundos" >> $log ##mandamos la fecha, datos, y los segundos y se redirigen al archivo .log
  sleep $intervalo
  segundos=$((segundos + intervalo))
done

lineas=$(cat $log | wc -l)
if [ $lineas -le 1 ]; then
  echo "No se recolectaron suficientes datos para graficar."
  exit 1
fi
echo "el proceso de PID: $PID termino"

echo "set terminal png" > grafica.txt
echo "set output \"$png\"" >> grafica.txt ## ">>" para  concatenar las lineas en el archivo
echo "set title \"$comando (PID: $PID)\"" >> grafica.txt
echo "set xlabel \"Segundos\"" >> grafica.txt
echo "set ylabel \"CPU %%\"" >> grafica.txt
echo "set y2label \"Memoria RSS (KB)\"" >> grafica.txt
echo "set y2tics" >> grafica.txt
echo "plot '$log' using 5:2 with lines title 'CPU', '$log' using 5:4 with lines title 'Memoria' axis x1y2" >> grafica.txt ##saca del archivo .log el dato de los segundos(eje x) y del porcentaje de cpu(eje y) //saca del archivo .log el dato de los segundos(eje x) y del porcentaje de memrss(eje y)
##mandamos todo lo necesario para hacer la grafica a  un archivo de texto  para gnuplot¿
gnuplot < grafica.txt
rm grafica.txt ##luego de mandarle el archivo de textp a gnuplot se elimina

echo "grafica guardada como $png"
