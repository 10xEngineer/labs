# 10xEngineer Labs Command Line Interface (CLI)

## Install

Labs CLI is distribute as RubyGems package. To install it you need to have Ruby installed (preferable 1.9.3)

	gem install labs

## Configure

Before you can use Labs CLI for a first time, run configuration.

	% labs configure
	Running 'labs configure' for first time.

	You API credentials are available from http://manage.10xlabs.net/

	API token: <ENTER-YOUR-TOKEN>
	API secret: <ENTER-YOUR-AUTH-SECRET>

	Using 'http://eu-1-aws.10xlabs.net' as default endpoint.

	Default configuration stored in /home/luke/.labs.rc.

## Create & access first fab machine

	% lab-machines create
	Machine 'black-pony' created.

	% lab-machines list
	+------------+---------+--------------------------------------+------------------+--------------------------+
	| Name       | State   | UUID                                 | Template         | Created                  |
	+------------+---------+--------------------------------------+------------------+--------------------------+
	| black-pony | created | 39aa3f60-0670-0130-936a-080027ca18f0 | ubuntu-precise64 | 2012-11-01T16:46:27.240Z |
	+------------+---------+--------------------------------------+------------------+--------------------------+	

	% lab-machines ssh black-pony
	Welcome to Ubuntu 12.04.1 LTS (GNU/Linux 3.2.0-30-virtual i686)

	lab@black-pony: $

