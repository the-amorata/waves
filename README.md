# W A V E S

Andres & Dan Fonseca decided to get in over their heads.
This is influenced by [the following instructions][].

### Set Up

Launch an [EC2][] instance with amazon's base AMI.

Allow traffic on port `8787` and `3838`

SSH into your instance. Use `sudo`, it will save you time/

```bash
sudo -i
```

Let's run some updates.

```bash
yum update
```

Do this swap file thing you don't fully understand

```bash
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

Alter your `fstab` file by adding `/swapfile   none    swap    sw    0   0`
to the end of it (`sudo vim /etc/fstab`)

Install R  with

```bash
yum install -y R
```

Install [Rstudio-Server][]

```bash
wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
yum install -y --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm
```

Install [Shiny][] (and other packages (from within `R` (but you MUST `sudo R`)))

```r
pkgs = c('shiny', 'data.table',  'tuneR', 'ggplot2',
         'colourpicker', 'extrafont', 'shinyjs')
lapply(pkgs, install.packages); rm(pkgs)
q()
```

*You probably want use the* `0-Cloud` *source for CRAN*

Install shiny-server

```bash
wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.1.759-rh5-x86_64.rpm
yum install -y --nogpgcheck shiny-server-1.4.1.759-rh5-x86_64.rpm
```

Make A New User

```bash
useradd your_username
echo "your_username:some_password" | chpasswd
```

Make Apps Directory

```bash
mkdir /home/your_username/apps/
```

Give Your New User Permissions

```bash
chown -R your_username:your_username /home/your_username/
```

Alter `/etc/shiny-server/shiny-server.conf` to like this:

```bash
# Instruct Shiny Server to run applications as the user "your_username"
run_as your_username;
# Define a server that listens on port 3838
server {
  listen 3838;
  # Define a location at the base URL
  location / {
    # Host the directory of Shiny Apps stored in this directory
    site_dir /home/your_username/apps/;
    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;
    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}
```

Restart Shiny-server

```bash
restart shiny-server
```

Install git

```bash
yum install -y git-core
```

And then mostly follow [these instructions][]. Especially as the sections 
"Initial Set Up" and "Synchronsising with Github." You'll have to log in to
your rstudio console to generate an SSH key to add to your github acount but
it's covered in the instructions (and more).

Clone the repo (inside `/home/your_username/apps/`)!

Then open the `waves-dev.Rproj file` (or like (switch to it, you know))

There is some trouble shooting you may have to do on this bit in the 
future but you get the idea. You may have to do one of these 
(SSH instead of HTTPS)

`git remote set-url origin git@github.com:username/repo.git`

### SSL Stuff??

```
sudo -i
mkdir /etc/ssl/private/
touch /etc/ssl/private/af.key
openssl genrsa -out /etc/ssl/private/af.key 2048
openssl req -new -x509 -key /etc/ssl/private/af.key -days 365 -sha256 -out /etc/ssl/certs/af.crt
```

This will ask you a few questions. The only crucial part is the Common Name. Here you need to enter the public DNS name or the public IP of your AWS instance. Again, note, that normally you would enter a domain name that you own, e.g. ‘shiny.ipub.com’ in my case. If you are just goofing around, enter the public DNS of your instance.


This is in `/etc/httpd/conf.d/af.conf` also remember to `mkdir /var/www/httpd`

```bash
yum install -y httpd24
yum install -y mod24_ssl
```

```bash
ServerName 54.165.9.152
Listen 8080

<VirtualHost *:80>
    Redirect permanent / https://54.165.9.152/
</VirtualHost>


<VirtualHost *:8080>
    <Location "/">
        SetHandler server-status
    </Location>
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot "/var/www/httpd"

    <Location "/">
        ProxyPass "http://localhost:3838/test/"
    </Location>

    SSLEngine On

    SSLCertificateFile /etc/ssl/certs/af.crt
    SSLCertificateKeyFile /etc/ssl/private/af.key
</VirtualHost>
```
But also follow [this link] if necessary.

----------

<!-- links -->
[shiny]: http://shiny.rstudio.com/
[ec2]: http://aws.amazon.com/ec2/
[rstudio-server]: https://www.rstudio.com/products/rstudio/download-server/
[these instructions]: http://r-pkgs.had.co.nz/git.html
[the following instructions]: https://github.com/chrisrzhou/RShiny-EC2Bootstrap
[this link]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-an-instance.html
