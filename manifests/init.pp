class oce {
	exec {"apt-get update": } ->
	exec {"apt-get upgrade -y": } ->
	package { "build-essential": ensure => installed, } ->
	package { "cmake": ensure => installed, } ->
	package { "xorg-dev": ensure => installed, } ->
	package { "freeglut3-dev": ensure => installed, } ->
	package { "libfreetype6-dev": ensure => installed, } ->
	package { "ftgl-dev": ensure => installed, } ->
	package { "git": ensure => installed, }

	exec { "get_oce": 
    command => "git clone https://github.com/tpaviot/oce.git oce",
    cwd => "/tmp",
    creates => '/tmp/oce',
    require => Package["git"],
  }

  exec { "update_oce":
    onlyif => '/usr/bin/test -f /tmp/oce',
    command => 'git pull',
    cwd => "/tmp/oce",
    require => Package["git"],
  }

  exec { "mkdir build; cd build":
		unless => '/usr/bin/test -f /tmp/oce/build',
		cwd => "/tmp/oce",
		require => Exec["get_oce"],
	} ->
	exec { "cmake":
		cwd => '/tmp/oce/build',
		command => 'cmake -DOCE_TESTING:BOOL=ON -DOCE_MULTITHREAD_LIBRARY:STRING=OPENMP -DOCE_WITH_GL2PS:BOOL=ON ..',
		creates => '/tmp/oce/build/Makefile',
	} ->
	exec { "make":
		cwd => '/tmp/oce/build',
		command => 'make -j4',
		timeout => 20000,
	} ->
	exec { "make install/strip":
		cwd => '/tmp/oce/build',
		command => 'make install/strip',
	} ->
	exec { "make test":
		cwd => '/tmp/oce/build',
	}
}