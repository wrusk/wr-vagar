# Lamp Manifest for Vagrant Provisioning
# run update
exec { "apt-get update":
  path => "/usr/bin",
}

# apache config
package { "apache2":
  ensure  => present,
  require => Exec["apt-get update"],
}
service { "apache2":
  ensure  => "running",
  require => Package["apache2"],
}
file { "/var/www/test":
  ensure  => "link",
  target  => "/vagrant/html",
  require => Package["apache2"],
  notify  => Service["apache2"],
}

#mysql 
# install mysql-server package
package { 'mysql-server':
  require => Exec['apt-get update'],        # require 'apt-update' before installing
  ensure => installed,
}

# ensure mysql service is running
service { 'mysql':
  ensure => running,
}

#php
# install php7 package
package { 'php7':
  require => Exec['apt-update'],        # require 'apt-update' before installing
  ensure => installed,
}

# ensure info.php file exists
file { '/var/www/html/info.php':
  ensure => file,
  content => '<?php  phpinfo(); ?>',    # phpinfo code
  require => Package['apache2'],        # require 'apache2' package before creating
} 

#phpmyadmin