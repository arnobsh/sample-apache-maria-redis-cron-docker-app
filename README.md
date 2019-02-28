# Apache2,MariaDB,Redis Setup With Docker

Simple Docker file to set up the apache2 server  to run Php, Mysql, and Redis

## Installation By `"docker"`

Use the following commands to set up the server

```
docker build -t sitename .
```

## Installation By `"docker-compose"`

For running by docker-compose simply run the following command


```
docker-compose up
```

It will automatically run the apache and insert into bash

After running the service you will go to the link http://localhost:80/ and find the PHP application

## Usage

1. Local Php APplication
2. Local MariaDB (Inside Docker)
3. Local Redis Caching(Inside Docker)

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Let me know if you have any questions regarding the setup or if you have faced any problem let me know by email arnobsh@gmail.com

## License
[MIT](https://choosealicense.com/licenses/mit/)