# W A V E S

Andres & Dan Fonseca decided to get in over their heads.

### Set Up

Launch an [EC2][] instance with amazon's base AMI.

Allow traffic on port `8787` and `3838`

SSH into your instance.

Do this swap file thing you don't fully understand

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Alter your `fstab` file by adding `/swapfile   none    swap    sw    0   0`
to the end of it (`sudo vim /etc/fstab`)

Install R  with `sudo yum install -y R`

Install [Rstudio-Server][]

```
wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
sudo yum install -y --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm
```

Install [Shiny][] (and other packages (from within `R` (but you MUST `sudo R`)))

```r
pkgs = c('shiny', 'data.table',  'tuneR', 
         'colourpicker', 'extrafont', 'shinyjs')
lapply(pkgs, install.packages); rm(pkgs)
q()
```

*You probably want use the* `0-Cloud` *source for CRAN*

Install shiny-server

```bash
wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.1.759-rh5-x86_64.rpm
sudo yum install -y --nogpgcheck shiny-server-1.4.1.759-rh5-x86_64.rpm
```

Make A New User

```
sudo useradd your_username
echo "your_username:some_password" | sudo chpasswd
```

Make Apps Directory

`mkdir /home/your_username/apps/`

Give Your New User Permissions

`sudo chown -R your_username:your_username /home/your_username/`

Alter `/etc/shiny-server/shiny-server.conf` to like this:

```
# Instruct Shiny Server to run applications as the user "your_username"
run_as your_username;
# Define a server that listens on port 80
server {
  listen 80;
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

`sudo restart shiny-server`

Install git

`sudo yum install git-core`

And then mostly follow [these instructions][]. Especially as the sections 
"Initial Set Up" and "Synchronsising with Github." You'll have to log in to
your rstudio console to generate an SSH key to add to your github acount but
it's covered in the instructions (and more).

Clone the repo (inside `/home/your_username/apps/`)!

Then open the `waves-dev.Rproj file` (or like (switch to it, you know))






----------

<!-- links -->
[shiny]: http://shiny.rstudio.com/
[ec2]: http://aws.amazon.com/ec2/
[rstudio-server]: https://www.rstudio.com/products/rstudio/download-server/
[these instructions]: http://r-pkgs.had.co.nz/git.html
