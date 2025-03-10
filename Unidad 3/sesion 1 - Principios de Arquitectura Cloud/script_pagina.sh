cat << EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mi Primer Servidor en AWS</title>
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
        h1 {
            color: #2c3e50;
        }
        h2 {
            color: #3498db;
        }
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
        <h2>Esta es mi primera instancia EC2</h2>
        <div class="info">
            <p><strong>Servidor:</strong> $(hostname)</p>
            <p><strong>IP Privada:</strong> $(hostname -I | awk '{print $1}')</p>
            <p><strong>Fecha de creación:</strong> $(date)</p>
            <p><strong>Versión de Ubuntu:</strong> $(lsb_release -d | cut -f2)</p>
        </div>
    </div>
</body>
</html>
EOF