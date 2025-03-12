#!/bin/bash
# Script de estrés con monitoreo detallado del sistema

# Crear directorio para almacenar resultados
RESULTS_DIR="./stress_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p $RESULTS_DIR
echo "Resultados se guardarán en: $RESULTS_DIR"

# Función para recopilar información del sistema
collect_system_info() {
    echo "=== INFORMACIÓN INICIAL DEL SISTEMA ===" > $RESULTS_DIR/system_info.txt
    echo "Fecha y hora: $(date)" >> $RESULTS_DIR/system_info.txt
    echo -e "\n=== INFORMACIÓN DE CPU ===" >> $RESULTS_DIR/system_info.txt
    lscpu >> $RESULTS_DIR/system_info.txt
    echo -e "\n=== INFORMACIÓN DE MEMORIA ===" >> $RESULTS_DIR/system_info.txt
    free -h >> $RESULTS_DIR/system_info.txt
    echo -e "\n=== INFORMACIÓN DE DISCO ===" >> $RESULTS_DIR/system_info.txt
    df -h >> $RESULTS_DIR/system_info.txt
    echo "Información del sistema guardada en $RESULTS_DIR/system_info.txt"
}

# Función para iniciar el monitoreo en segundo plano
start_monitoring() {
    echo "Iniciando monitoreo del sistema..."
    
    # Monitor de memoria (free)
    (
        echo "Timestamp,Total,Used,Free,Shared,Buff/Cache,Available" > $RESULTS_DIR/memory_free.csv
        while true; do
            TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
            MEM_DATA=$(free -m | grep Mem | awk '{print $2","$3","$4","$5","$6","$7}')
            echo "$TIMESTAMP,$MEM_DATA" >> $RESULTS_DIR/memory_free.csv
            sleep 5
        done
    ) &
    FREE_PID=$!
    
    # Monitor de estadísticas virtuales (vmstat) - captura cada 15 segundos
    (
        vmstat 15 > $RESULTS_DIR/vmstat.txt &
    )
    VMSTAT_PID=$!
    
    # Monitor adicional para CPU específicamente - mpstat captura cada 10 segundos
    if command -v mpstat &> /dev/null; then
        (
            mpstat -P ALL 10 > $RESULTS_DIR/mpstat.txt &
        )
        MPSTAT_PID=$!
        echo $MPSTAT_PID >> $RESULTS_DIR/monitor_pids.txt
    fi
    
    # Captura de 'top' periódicamente (muestras cada 30 segundos durante toda la prueba)
    (
        i=1
        end_time=$(($(date +%s) + TIMEOUT))
        while [ $(date +%s) -lt $end_time ]; do
            top -b -n 1 > $RESULTS_DIR/top_sample_$i.txt
            sleep 30
            i=$((i+1))
        done
    ) &
    TOP_PID=$!
    
    echo "Monitoreo iniciado con PIDs: $FREE_PID, $VMSTAT_PID, $TOP_PID"
    # Guardar PIDs para terminarlos después
    echo "$FREE_PID $VMSTAT_PID $TOP_PID" > $RESULTS_DIR/monitor_pids.txt
}

# Función para detener el monitoreo
stop_monitoring() {
    echo "Deteniendo procesos de monitoreo..."
    if [ -f "$RESULTS_DIR/monitor_pids.txt" ]; then
        for pid in $(cat $RESULTS_DIR/monitor_pids.txt); do
            kill $pid 2>/dev/null
        done
        echo "Monitoreo detenido"
    fi
}

# Verificar la memoria disponible antes de ejecutar
MEM_AVAILABLE=$(free -m | grep Mem | awk '{print $7}')
echo "Memoria disponible: $MEM_AVAILABLE MB"

# Calcular valores seguros (25% de la memoria disponible)
VM_BYTES=$((MEM_AVAILABLE / 4))
echo "Usando $VM_BYTES MB para pruebas de memoria"

# Carga de CPU (usando la mitad de los núcleos disponibles para no saturar completamente)
CPU_CORES=$(($(nproc) / 2))
[ $CPU_CORES -lt 1 ] && CPU_CORES=1
echo "Usando $CPU_CORES núcleo(s) para pruebas de CPU"

# Operaciones de E/S reducidas
IO_OPS=2
echo "Usando $IO_OPS operaciones de E/S"

# Tiempo de ejecución
TIMEOUT=1800  # 30 minutos - tiempo adecuado para analizar variaciones a lo largo del tiempo
echo "Ejecutando prueba durante $TIMEOUT segundos (30 minutos)"

# Recopilar información inicial del sistema
collect_system_info

# Iniciar monitoreo
start_monitoring

# Ejecutar pruebas de estrés
echo "Iniciando prueba de estrés..."
stress --cpu $CPU_CORES --io $IO_OPS --vm 1 --vm-bytes ${VM_BYTES}M --timeout $TIMEOUT > $RESULTS_DIR/stress_output.txt 2>&1 &
STRESS_PID=$!

# Operaciones adicionales de E/S
echo "Ejecutando operaciones de E/S adicionales..."
dd if=/dev/zero of=/tmp/test_file bs=1M count=100 > $RESULTS_DIR/dd_output.txt 2>&1 &
DD_PID=$!

# Búsqueda más limitada
echo "Ejecutando búsqueda en directorios específicos..."
find /var/log /etc -type f 2>/dev/null | xargs grep -l "error" 2>/dev/null > $RESULTS_DIR/find_results.txt &
FIND_PID=$!

# Esperar a que termine la prueba principal
echo "Prueba en ejecución. Por favor espere $TIMEOUT segundos..."
wait $STRESS_PID

# Detener otros procesos
kill $DD_PID $FIND_PID 2>/dev/null

# Recopilar información final
echo -e "\n=== INFORMACIÓN FINAL DEL SISTEMA ===" >> $RESULTS_DIR/system_info.txt
echo "Fecha y hora: $(date)" >> $RESULTS_DIR/system_info.txt
echo -e "\n=== INFORMACIÓN DE MEMORIA FINAL ===" >> $RESULTS_DIR/system_info.txt
free -h >> $RESULTS_DIR/system_info.txt

# Detener monitoreo
stop_monitoring

echo "Prueba de estrés completada"
echo "Todos los resultados están disponibles en: $RESULTS_DIR"

# Generar un informe resumido
echo "=== INFORME RESUMIDO ===" > $RESULTS_DIR/summary.txt
echo "Prueba ejecutada: $(date)" >> $RESULTS_DIR/summary.txt
echo "Duración: $TIMEOUT segundos ($(($TIMEOUT / 60)) minutos)" >> $RESULTS_DIR/summary.txt
echo "CPU cores utilizados: $CPU_CORES" >> $RESULTS_DIR/summary.txt
echo "Memoria utilizada: $VM_BYTES MB" >> $RESULTS_DIR/summary.txt
echo "Operaciones I/O: $IO_OPS" >> $RESULTS_DIR/summary.txt

# Analizar datos de CPU para el informe
echo -e "\n=== ANÁLISIS DE UTILIZACIÓN DE CPU ===" >> $RESULTS_DIR/summary.txt
echo "Extrayendo estadísticas de CPU desde los archivos de 'top'..." >> $RESULTS_DIR/summary.txt

# Extraer % de CPU de los archivos top
if ls $RESULTS_DIR/top_sample_*.txt &>/dev/null; then
    echo "Muestras de picos de CPU (ordenadas de mayor a menor):" >> $RESULTS_DIR/summary.txt
    for file in $RESULTS_DIR/top_sample_*.txt; do
        CPU_IDLE=$(grep "%Cpu" $file | awk -F',' '{print $4}' | awk '{print $1}')
        CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")
        timestamp=$(head -n 1 $file | awk '{print $3, $4, $5}')
        echo "$timestamp: $CPU_USAGE% utilización" >> $RESULTS_DIR/temp_cpu.txt
    done
    sort -rn -k 2 -t ':' $RESULTS_DIR/temp_cpu.txt | head -10 >> $RESULTS_DIR/summary.txt
    rm $RESULTS_DIR/temp_cpu.txt
fi

echo -e "\nComparación de memoria antes/después:" >> $RESULTS_DIR/summary.txt
head -n 15 $RESULTS_DIR/system_info.txt | grep Mem >> $RESULTS_DIR/summary.txt
tail -n 5 $RESULTS_DIR/system_info.txt | grep Mem >> $RESULTS_DIR/summary.txt

# Agregar información sobre la variación de carga
echo -e "\n=== VARIACIÓN DE CARGA A LO LARGO DEL TIEMPO ===" >> $RESULTS_DIR/summary.txt
echo "Ver archivos detallados en el directorio de resultados para análisis completo" >> $RESULTS_DIR/summary.txt
echo "Archivos clave para análisis:" >> $RESULTS_DIR/summary.txt
echo "- Para CPU: mpstat.txt y vmstat.txt" >> $RESULTS_DIR/summary.txt
echo "- Para memoria: memory_free.csv" >> $RESULTS_DIR/summary.txt

echo "Se ha generado un informe resumido en $RESULTS_DIR/summary.txt"
