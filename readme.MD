# backups-linux-server
You can make full and incremental copies of your server

#### REQUIREMENTS
```sh
$ apt install ncftp
```

#### HOW TO USE

You must configure the following parameters to make the custom copy

You will enter the folders you want to copy.
```sh
DIRS="/var /lib"
```
You must enter the data to access by FTP.
```sh
FTPU="USER-FTP"
FTPP="PASS-FTP"
FTPS="HOST-FTP"
``` 
You must add the url of the discord webhook to notify the copy.
```sh
WEBHOOK="url"
```

#### CRON JOB

To create a cron task so that the script runs every day at 24:00 PM we must do the following

```shell
crontab -e
```

Now we will add this line at the end of the whole

```sh
0 0 * * /router_script
``` 

#### START IT
```sh
$ chmod +x backup.sh
$ ./backup.sh
```