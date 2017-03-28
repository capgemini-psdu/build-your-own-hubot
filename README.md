[![Build Status](https://travis-ci.org/capgemini-psdu/build-your-own-hubot.svg?branch=master)](https://travis-ci.org/capgemini-psdu/build-your-own-hubot)

# PSD2obot

PSD2obot is a chat bot built on the [Hubot][hubot] framework. It was
initially generated by [generator-hubot][generator-hubot].

[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot

### Running PSD2obot Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](scripts.md#configuration) they rely upon have been set.


You can start PSD2obot locally by running:

    % bin/hubot

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    PSD2obot>

Then you can interact with PSD2obot by typing `PSD2obot help`.

    PSD2obot> PSD2obot help
    PSD2obot animate me <query> - The same thing as `image me`, except adds [snip]
    PSD2obot help - Displays all of the help commands that PSD2obot knows about.
    ...

### Scripts

More detail about scripting and which scripts are included with PSD2obot can be found in the [scripts](scripts.md) documentation.

##  Persistence

PSD2obot uses the `hubot-redis-brain` package (strongly suggested). This defaults to a [Redis][Redis] instance which is required to run on its default port 6379.

If you are testing locally and don't need any persistence feel free to remove the `hubot-redis-brain`
from `external-scripts.json` and you don't need to worry about redis at all.

[Redis]:https://redis.io/

## Adapters

Adapters are the interface to the service you want your hubot to run on, such
as Campfire or IRC. There are a number of third party adapters that the
community have contributed. Check [Hubot Adapters][hubot-adapters] for the
available ones.

If you would like to run a non-Campfire or shell adapter you will need to add
the adapter package as a dependency to the `package.json` file in the
`dependencies` section.

Once you've added the dependency with `npm install --save` to install it you
can then run hubot with the adapter.

    % bin/hubot -a <adapter>

Where `<adapter>` is the name of your adapter without the `hubot-` prefix.

[hubot-adapters]: https://github.com/github/hubot/blob/master/docs/adapters.md

## Slack Adaptor

PSD2obot is configured to use the Slack Adaptor.

> (Extract taken from [Slack API][slackapi] guide.)

You will need to set up a Custom Bot on your Slack team. This will create a token that your hubot can use to log into your team as a bot. Visit the [Custom Bot creation page][custom-slackbot] to register your bot with your Slack team, and to retrieve a new bot token.

Once you’ve got your bot set up as you like, you can run your hubot with the run script included (being sure to copy-and-paste your token in!):

    % HUBOT_SLACK_TOKEN=xoxb-YOUR-TOKEN-HERE ./bin/hubot --adapter slack

[slackapi]:https://slackapi.github.io/hubot-slack/
[custom-slackbot]:https://my.slack.com/apps/A0F7YS25R-bots

## Deploying to AWS

This section describes to manual process to set this up. We will automate this process at some point.

### Set up the necessary AWS infra

#### Create a virtual machine

A t2.micro EC2 instance running AWS Linux is sufficient.


#### Prepare the EC2 instance to run your application

First we need to install the main dependencies: git, npm and redis. SSH to the machine, install git:

    % yum install git

Create a new SSH key pair and add the public key to your GitHub account in the usual way.

Next install npm. See https://nodejs.org/en/download/package-manager/ for details about node and the AWS documentation http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html for details of how to do this on AWS Linux.

The download and installation of Redis as a service has been automated and can be completed by the following commands:

    % wget https://gist.githubusercontent.com/yenkeecg/b00edfcc3476fb6d208eb5546b874673/raw/install-redis.sh
    % chmod 777 install-redis.sh
    % ./install-redis.sh

### Deploying the application

You should now be able to pull the project code and run the application:

    % git clone git@github.com:capgemini-psdu/build-your-own-hubot.git
    % cd build-your-own-hubot
    % npm install
    % HUBOT_SLACK_TOKEN=xoxb-YOUR-TOKEN-HERE ./bin/hubot --adapter slack


### Deploying to UNIX or Windows

The default Hubot documentation comes with a link with vague instructions about how to deploy to a UNIX operating system. Please check out the [deploying hubot onto UNIX][deploy-unix]  wiki page if you would like more information.

[deploy-unix]: https://github.com/github/hubot/blob/master/docs/deploying/unix.md

### Installing the application as an OS service

We recommend that you configure the application to run via upstart so that it automatically restarts after e.g. the EC2 instance is rebooted.

Create the upstart job configuration:

`sudo vi /etc/init/hubot.conf`

Example contents for this file are supplied below:

```
description "Hubot upstart script"

start on filesystem or runlevel [2345]
stop on runlevel [!2345]

# Restart upon crash
respawn
# Moving average maximum 5 restarts in 60 seconds
respawn limit 5 60

script
  cd /home/ec2-user/build-your-own-hubot
  export PATH="/home/ec2-user/build-your-own-hubot/node_modules/.bin:/home/ec2-user/build-your-own-hubot/node_modules/hubot/node_modules/.bin:/home/ec2-user/.nvm/versions/node/v6.10.0/bin:$PATH"
  HUBOT_SLACK_TOKEN=xoxb-YOUR-TOKEN-HERE ./bin/hubot --adapter slack >> /var/log/hubot.log 2>&1
end script

```

You should then be able to start and stop the application using upstart e.g.:

```
sudo start hubot
sudo stop hubot
sudo restart hubot
```
### AWS S3 Backup

PSD2obot uses a AWS S3 bucket to backup it's brain. This is enabled by the 'hubot-s3-brain-aws.coffee' script. In order for the script to work, there are a few parameters to set on hubot startup. These can be added to the .conf upstart script mentioned in the previous section.

The three parameters are:
- HUBOT_S3_BRAIN_BUCKET - specifies the bucket name where the brain is backed up.
- HUBOT_S3_BRAIN_SAVE_INTERVAL - interval in seconds for brain storage. PSD2obot has been set for a 24 hour interval.
- HUBOT_S3_BRAIN_NOT_REQUIRED - switches off s3 storage when true to allow local running/testing of PSD2obot.

The backup script is a lightly modified version of the npm packaged hubot-s3-brain script which uses more security credential parameters. The original script can be found at: https://www.npmjs.com/package/hubot-s3-brain
