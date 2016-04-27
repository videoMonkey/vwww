# == Class: php5::install
# installing all the php modules that we need
class php5::install {

    # the php packages we need.
    package { 'php5-cli': require => Exec['apt-update'], }
    package { [
        'libapache2-mod-php5',
        'php-pear',
        'php5',
        'php5-apcu',
        'php5-dev',
        'php5-common',
        'php5-curl',
        'php5-gd',
        'php5-imagick',
        'php5-imap',
        'php5-ldap',
        'php5-memcache',
        'php5-mcrypt',
        'php5-mysql',
        'php5-redis',
        'php5-xdebug',
      ]:
      ensure  => latest,
      require => [
        Exec['apt-update'],
        Package[
          'apache2',
          'curl',
          'imagemagick',
          'memcached',
          'php5-cli'
        ],
      ],
      # apparently restarting apache reloads the modules list?
      # and then you can use them
      notify  => Service['apache2'],
    }

    # some other services that we need
    package { [
        'imagemagick',
        'memcached',
        'postfix',
        'gettext',
      ]:
      ensure  => latest,
      require => Exec['apt-update']
    }

    file { '/var/www/html/index.php':
      ensure  => present,
      content => '<h1>VWWW</h1><?php phpinfo();',
      mode    => '0644',
      require => Package['apache2', 'php5']
    }

    file { '/var/www/html/index.html':
      ensure  => absent,
      require => [
        Package['apache2', 'php5'],
        File['/var/www/html/index.php'],
      ],
    }

    file { 'php.ini':
      ensure  => present,
      name    => '/etc/php5/apache2/php.ini',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/php5/php.ini',
      require => Package['apache2', 'php5'],
      notify  => Service['apache2'],
    }

}