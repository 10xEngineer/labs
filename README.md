# 10xEngineer Labs Command Line Interface (CLI)

## Install

Labs CLI is distribute as RubyGems package. To install it you need to have Ruby installed (preferable 1.9.3)

	gem install labs

For more about Labs, check http://10xengineer.me/labs/ 

## Configure

Before you can use Labs CLI for a first time, run configuration.

	% labs configure
	Running 'labs configure' for first time.

	You API credentials are available from http://manage.10xlabs.net/

	API token: <ENTER-YOUR-TOKEN>
	API secret: <ENTER-YOUR-AUTH-SECRET>

	Using 'http://eu-1-aws.10xlabs.net' as default endpoint.

	Default configuration stored in /home/luke/.labs.rc.

You can get/regenerate API credentials in your user profile under 'API Keys' menu item.

## Create & access first Lab machine

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
	lab@black-pony: $ exit

Currently all machines have a 'default' SSH key from your profile.

## Copyright 

Copyright © 2012, 10xEngineer Ltd. All rights reserved.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

