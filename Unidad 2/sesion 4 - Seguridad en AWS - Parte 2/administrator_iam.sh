# Crear grupo
aws iam create-group --group-name Group-Adm

#  Asociar politica de administrador al grupo
aws iam attach-group-policy \
    --group-name Group-Adm \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
	
# Listar politicas asociadas a un grupo
# aws iam list-attached-group-policies --group-name <nombre del grupo>
aws iam list-attached-group-policies --group-name Group-Adm
	
# Crear el usuario user-adm
aws iam create-user --user-name "user-adm"

# Establecer una contraseña para que el usuario pueda conectarse a la consola de AWS
aws iam create-login-profile --user-name user-adm --password "User-adm"

# Crear credenciales de acceso desde aws cli
aws iam create-access-key --user-name user-adm

# Asociar el usuario "user-adm" al grupo "Group-Adm"
# aws iam add-user-to-group --group-name <nombre del grupo> --user-name <nombre del usuario>
aws iam add-user-to-group --group-name Group-Adm --user-name user-adm

# Listar usuarios asociados al grupo "Group-Adm"
# aws iam get-group --group-name <NombreDelGrupo>
aws iam get-group --group-name Group-Adm	

Ejemplo enlace de acceso par los usuarios de la cuenta
https://<id cuenta>.signin.aws.amazon.com/console

Mas adelante crear las siguentes politicas

-CI_CD: CI_CD.json
-ContainersPolicy: ContainersPolicy.json
-CloudWatchPolicy: CloudWatchPolicy.json
-ElasticBeanstalkPolicy: ElasticBeanstalkPolicy.json
-LambdaApiGPolicy: LambdaApiGPolicy.json
-RdsPolicy: RdsPolicy.json
-DocumentDBPolicy: DocumentDBPolicy.json
-CloudformationPolicy: CloudformationPolicy .json
-SNS, SQS,SES: sns_sqs_sesPolicy.json


Ojo(si requieren reiniciar aws cli)
borrar contenido de archivos
nano ~/.aws/credentials
nano ~/.aws/config
