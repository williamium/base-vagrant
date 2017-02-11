# My Vagrant Set-up

This is my local Vagrant set-up which was based on [Vaprobash][].

## Details

See the Vaprobash documentation for configuration. I have stripped things out that I don't need, and changed some things that I do.

- You can choose between different versions of PHP.
- You can choose between different versions of MySQL and MariaDB.
- Nginx is the only server available, but you could easily add Apache or another.
- Remote SQL access is enabled without the need for an SSH tunnel
- Easy to change any configuration.

This set-up allows multiple domains/hosts on the one Vagrant box. Example usage:

```
/home/vagrant/sites/example1.com/vagrant/nginx/example1.com.conf
/home/vagrant/sites/example1.com/vagrant/db/init/example1.sql

/home/vagrant/sites/example2.com/vagrant/nginx/example2.com.conf
/home/vagrant/sites/example2.com/vagrant/db/init/example2.sql

/home/vagrant/sites/example3.com (no vagrant directory)
```

In the above example, when you initialise the vagrant box, it will look for all of your projects.

- If it does not have an Nginx config file, no host will automatically be created.
- If it does not have a SQL init file, no database will automatically be created. If there is a file, the database will be created (named based on the file name) and the SQL executed (for example to create tables and insert data).

Therefore example1.com and example2.com will both be available on our Vagrant box immediately, but example3.com will not. However, you can manually create the Nginx configuration, and a database (if needed) and enable the site that way. The databases would be created as "example1" and "example2" automatically as this is the filename. Any dots/periods in the filename would be converted to underscores e.g example1.dev.sql would result in a database named "example1_dev".

[Vaprobash]: https://github.com/fideloper/Vaprobash