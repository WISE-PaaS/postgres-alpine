# postgres-alpine

This docker image allows the WISE-PaaS users to deploy a container to the platform, enter the shell of the container, and then use the **psql** command to navigate the data they have inserted to the Postgresql database. The reason for doing this is that only **dedicated** database owners are allowed to log into the database remotely from their local machines with the external host address provided by the WISE-PaaS Service Portal. Therefore, the users that only subscribe to the **shared** database service can use this image to do the work.

# Steps

## 1. Deploy

Deploy the pod using the YAML config file inside the ``k8s/`` folder. You may decide to build your own image with the Dockerfile included in this project or just go ahead and deploy with the image specified in the YAML file.

```shell
$ kubectl apply -f k8s/
```

Check the pod in your namespace and make sure the pod's status is ``Running``.

```shell
$ kubectl get pod

NAME                                        READY   STATUS    RESTARTS   AGE
postgres-dev-5cc5f99cb5-z5zbn               1/1     Running   0          60s
```

<br>

## 2. Enter the Shell

```shell
$ kubectl exec -it postgres-dev-5cc5f99cb5-z5zbn sh
/ #
```

<br>

## 3. Log into the Database with psql

Use the following command and replace the fields with your credentials before you send the command.

```shell
$ psql postgres://[username]:[password]@[host]:[port]/[database]
```

For example, The credentials you get from the Service Portal may look as following:

```
{
  "binding_name": "iot-home-k8s-level2-secret",
  "credentials": {
    "database": "b39b994c-298d-4d13-bd67-b443fe35441f",
    "externalHosts": "52.163.226.41:5432",
    "host": "10.0.9.102",
    "internalHosts": "10.0.9.102:5432",
    "password": "kxmGgvlB2KQsqdwZ23IOabcde",
    "port": 5432,
    "uri": "postgres://5e886c55-82b6-4a37-aa08-a312682399dc:kxmGgvlB2KQsqdwZ23IOabcde@10.0.9.102:5432/b39b994c-298d-4d13-bd67-b443fe35441f",
    "username": "5e886c55-82b6-4a37-aa08-a312682399dc"
  },
  "instance_name": "postgresql",
  "label": "PostgreSQL"
}
```

Then you can take the ``uri`` connection string and combine it with the **psql** command to log into the database.

```shell
$ psql postgres://5e886c55-82b6-4a37-aa08-a312682399dc:kxmGgvlB2KQsqdwZ23IOabcde@10.0.9.102:5432/b39b994c-298d-4d13-bd67-b443fe35441f
psql (12.2, server 10.1)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

b39b994c-298d-4d13-bd67-b443fe35441f=>
```

Now, you are in!

<br>

## 4. Make a Query

Let's take our _iot-home_ project as an example. The following query retrieves the latest 10 rows from the ``temperature`` table. Remember to put a semicolon at the end of a query so that the **psql** knows you have done entering the SQL commands and executes it right away.

```shell
b39b994c-298d-4d13-bd67-b443fe35441f=> SELECT * from livingroom.temperature ORDER BY timestamp DESC LIMIT 10;
    id    |       timestamp        | temperature
----------+------------------------+-------------
 36168883 | 2020-05-13 14:56:29.75 |          27
 36168882 | 2020-05-13 14:56:26.74 |          26
 36168881 | 2020-05-13 14:56:23.74 |          23
 36168880 | 2020-05-13 14:56:20.74 |          28
 36168879 | 2020-05-13 14:56:17.74 |          23
 36168878 | 2020-05-13 14:56:14.73 |          26
 36168877 | 2020-05-13 14:56:11.73 |          22
 36168876 | 2020-05-13 14:56:08.73 |          28
 36168875 | 2020-05-13 14:56:05.73 |          23
 36168874 | 2020-05-13 14:56:02.73 |          27
(10 rows)

b39b994c-298d-4d13-bd67-b443fe35441f=>
```

Now, we have successfully executed an SQL query with an internal host IP address.

# YAML Config File

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
      tool: psql
  template:
    metadata:
      labels:
        app: postgres
        tool: psql
    spec:
      containers:
        - name: postgres
          image: ensaas/postgres-alpine
          imagePullPolicy: Always
          resources:
            limits:
              cpu: 20m
              memory: 128Mi
              ephemeral-storage: 128Mi
            requests:
              cpu: 20m
              memory: 128Mi
```

