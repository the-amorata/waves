# W A V E S

Andres & Dan Fonseca decided to get in over their heads.

### Set Up

Launch an [EC2][] instance with amazon's base AMI.

Allow traffic on port `8787` and `3838`

SSH into your instance.

Do this swap file thing you don't fully understand

```
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

Install [Shiny][] (and other packages (from within `R`))

```
install.packages("shiny")
install.packages("ggplot2")
install.packages("data.table")
install.packages("tuneR")
```

*You probably want use the* `0-Cloud` *source for CRAN*

Install shiny-server

```
wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.1.759-rh5-x86_64.rpm
sudo yum install -y --nogpgcheck shiny-server-1.4.1.759-rh5-x86_64.rpm
```

Install git

`sudo yum install git-core`








----------

<!-- links -->
[shiny]: http://shiny.rstudio.com/
[ec2]: http://aws.amazon.com/ec2/
[rstudio-server]: https://www.rstudio.com/products/rstudio/download-server/
