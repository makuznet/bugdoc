# Mirror The Doc Site

>  This repo when installed on a `hasinet` host:  
> — mirrors the [site's](https://www.chiark.greenend.org.uk/~sgtatham/bugs.html) content;  
> — builds the custom Nginx Docker image having the mirrored content;  
> — sends the image and the Bash script to a `noinet` host to get the Docker image loaded and run;    
> 
> If Docker is not available:  
> — Installs Nginx web server on a `noinet` host and fill it with the mirrored docs.
>
> Cron job is added to the `hasinet` host to update the site content on a weekly basis, renew the Docker image and start (restart) the container.

## Prerequisites
These parts haven't been automated yet, so check whether they are tuned.
### Debian 10
This repo has been tested with Debian 10.
### Docker
Make sure Docker is in place both on `hasinet` and on `noinet` hosts.  
Else read Usage section.  
### Make
Install `make` as Debian doesn't have it by default:
```shell
sudo apt install make
```
### Sudo
Make sure sudo is in place both on `hasinet` and on `noinet` hosts. Else do:
```shell
su -
apt install sudo
usermod -aG sudo makuznet
getent group sudo
exit # ssh session
$ sudo echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
```
### ssh pub key and sshd_config
Make sure ssh auth uses keys not passwords. Else do:  
#### On `hasinet` host
Copy an id_rsa private key to your username ~/.ssh dir.
#### On `noinet` host
Make a file named `authorized_keys` in your username ~/.ssh dir.    
Copy an id_rsa.pub file content to the `authorized_keys` file.  
Uncomment `PasswordAuthentication no` in /etc/ssh/sshd_config.  
Uncomment `PubkeyAuthentication yes` in /etc/ssh/sshd_config.  

## Usage  

It is crucial to run all the `make` commands from the dir `~/bugdoc`.  
This is because of Docker as Dockerfile operates with relative paths to build a custom Docker image.

> All the commands are executed from the `hasinet` host !

### To mirror the site and start (restart) the Docker container with the mirrored content on the `noinet` host:
```shell
cd ~/bugdoc 
make sync deploy cron -f ~/bugdoc/makefile user=<your_username> noinetip=<no_inet ip addr>
```
`cron` will add a job to run this command on a weekly basis.

### To mirror just one language and start (restart) the Docker container:
```shell
cd ~/bugdoc
make sync_lang deploy -f ~/bugdoc/makefile user=<your_username> noinetip=<no_inet ip addr> lang=bugs-ru
```
`lang=`  
English: bugs  
Russian: bugs-ru  
Languages available: bugs-(br, ch, cz, da, de, es, fr, hu, it, jp, nl, pl, ru, tw)  

### As an alternative to Docker
#### Install Nginx web server on `noinet` host:
```shell
make nginx -f ~/bugdoc/makefile user=<your_username> noinetip=<no_inet ip addr>
```
#### And update the mirrored content:
```shell
make alt_sync alt_cron -f ~/bugdoc/makefile user=<your_username> noinetip=<no_inet ip addr>
```
`alt_cron` will add a job to run this command on a weekly basis.

## Installation  
### Clone this repo to 'hasinet' host in your username dir
You will get `~/bugdoc` dir, where all the repo files are.

```shell
git clone https://gitlab.rebrainme.com/devops_users_repos/1976/ansible-vault
```

## Commands and Keys
Run make:
```shell
make -f /tmp/makefile
```

Install Docker:
```shell 
wget -O - https://get.docker.com | bash -
```

Docker relative paths explanation:
```shell
FROM nginx
COPY bugs /usr/share/nginx/html

~
    bugdoc
            makefile
            Dockerfile
            bugs
                bugs.html
                bugs-ru.html
```
Run `docker build` command from ~/bugdoc ! Then COPY bugs will work !

Build a custom docker image:
```shell
docker build -t bugdoc
```
-t — tag   
bugdoc — tag name  


Save a Docker image:  
```shell
docker save -o /tmp/bugdoc.tar bugdoc:latest
```
-o — Write to a file, instead of STDOUT  


Load an image from a tar archive
```shell
docker load -i /tmp/bugdoc.tar
```
-i — input, read from tar archive file, instead of STDIN  


Check whether Docker is working:  
```shell
docker ps
```

Download a Docker container image with Nginx:
```shell
docker pull nginx
```

Run a Docker container 
```shell
docker --rm -d -p 80:80 nginx
```

Download a static web site content:
```shell
sudo wget -P ~/bugdoc/bugs/ --reject-regex='\w*@\w*.\w*.\w{3}' -e robots=off -nd -m -np https://www....
```
-P — prefix, set a dir to save files to  
--regect-regex — regular expression excluding some links from being mirrored  
'\w*@\w*.\w*.\w{3}' — user@example.domain.com  
-e robots=off — do not include robots.tx file when mirroring  
-nd — do not repeat web site dirs hierarchy  
-m — mirror, recursive download provided a file has links inside  
-np — no parents, don't ascent higher in web site dirs hierarchy then stated  


Make a list of files in some dir with Vim:
```shell
vim .
```

## Acknowledgments

This repo was inspired by [SkillFactory](http://skillfactory.ru/) team

## See Also

- [Site to mirror](https://www.chiark.greenend.org.uk/~sgtatham/bugs.html) 
- [Makefile handbook](https://bit.ly/make-handbook)
- [Makefile handbook site](https://makefile.site/)
- [Crontab guru](https://crontab.guru/)
- [Offline Mirror of a Site with 'wget'](https://www.guyrutenberg.com/2014/05/02/make-offline-mirror-of-a-site-using-wget/)
- [Building custom Nginx image](https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/)
- [SSH connection from noinet to hasinet host](https://unix.stackexchange.com/questions/116867/serve-internet-to-remote-machine-via-ssh-session)
- [How to run commands via SSH](https://www.cyberciti.biz/faq/unix-linux-execute-command-using-ssh/)
- [docker build](https://docs.docker.com/engine/reference/commandline/build/)
- [Copying Content from the Docker Host](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-docker/#manage_copy)
- [Docker Docs](https://docs.docker.com/engine/reference/commandline/docker/)

## License
Follow Debian, Docker, GNU, Nginx, etc. lincenses terms and conditions.