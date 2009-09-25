# MySQLPatch #

A MySQL client patch for Quartz Composer.

## Compilation Notes ##

The master branch contains an Xcode project for dynamically linking to libmysqlclient.

From the command line:

> $ mysql_config  
> Usage: /usr/local/mysql/bin/mysql_config [OPTIONS]  
> Options:  
>  --cflags         [-I/usr/local/mysql/include -Os -arch i386 -fno-common]  
>  --include        [-I/usr/local/mysql/include]  
>  --libs           [-L/usr/local/mysql/lib -lmysqlclient -lz -lm]  
>  --libs_r         [-L/usr/local/mysql/lib -lmysqlclient_r -lz -lm]  
>  --socket         [/tmp/mysql.sock]  
>  --port           [3306]  
>  --version        [5.0.51a]  
>  --libmysqld-libs [-L/usr/local/mysql/lib -lmysqld -lz -lm]  

Please edit the Build parameters of MySQLPatch in the Targets drop down and change the following fields:

Other Linker Flags: -lmysqlclient -lz -lm  
Header Search Paths: /usr/local/mysql/include  
Library Search Paths: /usr/local/mysql/lib  

## Static Library ##

There is a branch called 'static_library' containing a copy of libmysqlclient.a. I haven't tested it on another machine, but it might work properly.