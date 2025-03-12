#!/bin/bash
# Script modificado para generar carga con menos requisitos de memoria

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

# Tiempo de ejecución reducido inicialmente para pruebas
TIMEOUT=300  # 5 minutos, puedes ajustarlo después
echo "Ejecutando prueba durante $TIMEOUT segundos"

# Ejecutar con parámetros ajustados
echo "Iniciando prueba de estrés..."
stress --cpu $CPU_CORES --io $IO_OPS --vm 1 --vm-bytes ${VM_BYTES}M --timeout $TIMEOUT

# Operaciones adicionales de E/S más ligeras
echo "Ejecutando operaciones de E/S adicionales..."
dd if=/dev/zero of=/tmp/test_file bs=1M count=100 &
DD_PID=$!

# Búsqueda más limitada para reducir carga
echo "Ejecutando búsqueda en directorios específicos..."
find /var/log /etc -type f 2>/dev/null | xargs grep -l "error" 2>/dev/null &
FIND_PID=$!

# Esperar a que termine la prueba principal
echo "Esperando a que finalice la prueba principal..."
wait $DD_PID $FIND_PID

echo "Prueba de estrés completada"
