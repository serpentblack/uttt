#!/bin/bash
# Múltiples técnicas de generación de carga
stress --cpu $(nproc) --io 4 --vm 2 --vm-bytes 1G --timeout 3600 &
dd if=/dev/zero of=/dev/null bs=1M count=10000 &
find / -type f | xargs grep -l "patrón" > /dev/null &