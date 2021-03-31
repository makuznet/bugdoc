.PHONY: sync sync_lang deploy nginx alt_sync cron alt_cron

# Mirroring the documentation
sync:
		# Mirroring the site content
		wget -P ~/bugdoc/bugs/ --reject-regex='\w*@\w*.\w*.\w{3}' -e robots=off -nd -m -np https://www.chiark.greenend.org.uk/~sgtatham/bugs.html

# Mirroring the Documentation in some language
sync_lang:
		wget -P ~/bugdoc/bugs/ -nd -np https://www.chiark.greenend.org.uk/~sgtatham/$(lang).html

# Rolling out Docker based Nginx with the documentation
deploy:	
		# Telling Docker where the content to merge is located	
		sudo printf "FROM nginx\nCOPY bugs /usr/share/nginx/html\n" > ~/bugdoc/Dockerfile
		# Merging content with Nginx Docker image
		sudo docker build -t bugdoc .
		# Making a tar file to move the custom Docker image
		sudo docker save -o /tmp/bugdoc.tar bugdoc:latest
		# Conveying the image to a remote host
		scp ~/bugdoc/bugdoc.* $(user)@$(noinetip):/tmp
		# Fuse the image in the Docker on the remote host
		ssh $(noinetip) -l $(user) 'sudo docker load -i /tmp/bugdoc.tar'
		# Checking whether the container is up and if not starting it, else restarting
		ssh $(noinetip) -l $(user) 'sudo /tmp/bugdoc.sh'

# Installing Nginx as on the remote host without Internet access		
nginx:
		# Download Nginx packages and dependencies
		sudo apt install -y --download-only nginx
		# Making an archive
		sudo tar --exclude='./lock' --exclude='./partial' -czvf /tmp/nginx.tar.gz -C /var/cache/apt/archives .
		# Delivering the archive
		scp /tmp/nginx.tar.gz $(user)@$(noinetip):/tmp
		# Unarchiving and putting to a dir named after the archive
		ssh $(noinetip) -l $(user) 'sudo tar -xzvf /tmp/nginx.tar.gz -C /var/cache/apt/archives/ --one-top-level'
		# Installing Nginx on remote site
		ssh $(noinetip) -l $(user) 'sudo apt install -y /var/cache/apt/archives/nginx/*.deb'
		# Removing installation files
		ssh $(noinetip) -l $(user) 'sudo rm -rfv /var/cache/apt/archives/nginx'
		# Starting Nginx
		ssh $(noinetip) -l $(user) 'sudo systemctl start nginx'
		# Enabling Nginx
		ssh $(noinetip) -l $(user) 'sudo systemctl enable nginx'

# Updating the content of Nginx
alt_sync:
		# Mirroring the docs
		make sync
		# Making a tar file
		tar -czvf /tmp/bugs.tar.gz -C ~/bugdoc/bugs .
		# Conveying
		scp /tmp/nginx.tar.gz $(user)@$(noinetip):/tmp
		# Unarchiving and copying
		ssh $(noinetip) -l $(user) 'sudo tar -xzvf /tmp/bugs.tar.gz -C /usr/share/nginx/html'
		# Reloading Nginx
		ssh $(noinetip) -l $(user) 'sudo systemctl reload nginx'

# Cron job for deploy task
cron:
		sudo grep 'root /usr/bin/make sync deploy' /var/spool/cron/crontabs/root || sudo crontab -u root -l | { sudo cat; sudo echo "45 3 * * sat root /usr/bin/make sync deploy -f ~/bugdoc/makefile user=makuznet noinetip=10.0.2.14"; } | sudo crontab -

# Cron job for alt_sync task
alt_cron:
		sudo grep 'root /usr/bin/make alt_sync' /var/spool/cron/crontabs/root || sudo crontab -u root -l | { sudo cat; sudo echo "45 3 * * sat root /usr/bin/make alt_sync -f ~/bugdoc/makefile user=makuznet noinetip=10.0.2.14"; } | sudo crontab -		