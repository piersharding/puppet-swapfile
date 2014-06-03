# == Class: swapfile
#
# Full description of class swapfile here.
#
# === Parameters
#
# [size]
#   How big to make the swapfile in Mb - default: 2048
#
#
# === Examples
#
#  class { swapfile:
#    size => 2048,
#  }
#
# === Authors
#
# Piers Harding <piers@ompka.net>
#
# === Copyright
#
# Copyright 2014 Piers Harding.
#
#
class swapfile ($size = 2048
    ) inherits ::swapfile::params {

    if ! is_integer($size) {
        fail("Class['swapfile']: swapfile size must be an integer eg: 2048")
    }

        exec { "create swap file":
        command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=$size",
        creates => "/var/swap.1",
    }

    exec { "attach swap file":
        command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
        require => Exec["create swap file"],
        unless => "/sbin/swapon -s | grep /var/swap.1",
    }

# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# /var/swap.1           swap                   swap    defaults        0 0

    # augeas{ "swapfile" :
    #     context => "/files/etc/fstab",
    #     changes => [
    #         "set spec[last()+1 = '/var/swap.1']/spec /var/swap.1",
    #         "set spec[last() = '/var/swap.1']/file swap",
    #         "set spec[last() = '/var/swap.1']/vfstype swap",
    #         "set spec[last() = '/var/swap.1']/opt[1] defaults",
    #         "set spec[last() = '/var/swap.1']/dump 0",
    #         "set spec[last() = '/var/swap.1']/passno 0",
    #     ],
    # }

    # mount { "acativate_swapfile":
    #     ensure      => "mounted",
    #     atboot      => true,
    #     device      => "/var/swap.1",
    #     dump        => 0,
    #     fstype      => "swap",
    #     options     => "swap",
    #     pass        => 0,
    #     require => Exec["attach swap file"]
    # }

    # from stdlib
    file_line { "acativate_swapfile":
        path    => "/etc/fstab",
        line    => "/var/swap.1           swap                   swap    defaults        0 0",
        ensure  => present,
        require => Exec["attach swap file"]
    }

}
