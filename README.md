# Scripts

This repository is used to saved different scripts used in Drupal projects.

* create-docker-project.sh: This script create a new docker project in Linux
* dns-docker-daemon.sh: This script fix the problem about "Docker Could not resolve 'deb.debian.org'" adding a DNS to daemon.json
* drupal-webiste-audit.sh: This script is used to create a new audit for Drupal 8/9 websites.
* collate-charset-db.sh: This script allow us to change the collate and charset of .sql file

Please set permissions 777 to the script to run this script without sudo user, for example:

```bash
chmod 777 create-docker-project.sh
```
