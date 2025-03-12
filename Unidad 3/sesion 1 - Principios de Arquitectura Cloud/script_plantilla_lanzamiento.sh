#!/bin/bash
# Generar página web dinámica al iniciar la instancia
HOSTNAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
CREATION_DATE=$(date)
UBUNTU_VERSION=$(lsb_release -d | cut -f2)

cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Instancia EC2 Única</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        h1 { color: #2c3e50; }
        h2 { color: #3498db; }
        .info {
            background-color: #e8f4f8;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>¡Hola desde AWS Academy!</h1>
        <h2>Esta es una instancia EC2 única</h2>
        <div class="info">
            <p><strong>Nombre del Servidor:</strong> $HOSTNAME</p>
            <p><strong>Dirección IP Privada:</strong> $PRIVATE_IP</p>
            <p><strong>Fecha de Creación:</strong> $CREATION_DATE</p>
            <p><strong>Versión de Sistema:</strong> $UBUNTU_VERSION</p>
        </div>
    </div>
</body>
</html>
EOF
