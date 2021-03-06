# Scripts Detail

### PSD2obot Configuration

PSD2obot can be configured with scripts available at from github [hubot-scripts][hubot-scripts] repository. Details for running each of the scripts can be found on the [hubot scripts catalogue][hubot-catalog].

[hubot-scripts]:https://github.com/github/hubot-scripts.git
[hubot-catalog]:http://hubot-script-catalog.herokuapp.com/

### Environment Variables

A few scripts (including some installed by default) require environment
variables to be set as a simple form of configuration.

Each script should have a commented header which contains a "Configuration"
section that explains which values it requires to be placed in which variable.
When you have lots of scripts installed this process can be quite labour
intensive. The following shell command can be used as a stop gap until an
easier way to do this has been implemented.

    grep -o 'hubot-[a-z0-9_-]\+' external-scripts.json | \
      xargs -n1 -I {} sh -c 'sed -n "/^# Configuration/,/^#$/ s/^/{} /p" \
          $(find node_modules/{}/ -name "*.coffee")' | \
        awk -F '#' '{ printf "%-25s %s\n", $1, $2 }'

How to set environment variables will be specific to your operating system.
Rather than recreate the various methods and best practices in achieving this,
it's suggested that you search for a dedicated guide focused on your OS.

### Scripting

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide][scripting-docs].

For many common tasks, there's a good chance someone has already one to do just
the thing.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

#### PSD2obot Environment variables

PSD2obot has file in config/.env to hold environment variables. The current selection of scripts requires the following to be populated:

    REDIS_URL=redis://<auth>@localhost:6379/<prefix>
    KARMA_ALLOW_SELF=false

Some of the scripts require environment variables set on hubot startup. This can be automated in the hubot upstart .conf script. The current script entry for psd2obot looks like:

```
script
  cd /home/ec2-user/build-your-own-hubot
  export PATH="/home/ec2-user/build-your-own-hubot/node_modules/.bin:/home/ec2-user/build-your-own-hubot/node_modules/hubot/node_modules/.bin:/home/ec2-user/.nvm/versions/node/v6.10.0/bin:$PATH"
  export HUBOT_S3_BRAIN_BUCKET=psd2obot-redis-backup
  export HUBOT_S3_BRAIN_SAVE_INTERVAL=86400
  export HUBOT_S3_BRAIN_NOT_REQUIRED=false
  HUBOT_SLACK_TOKEN=xoxb-YOUR-TOKEN-HERE ./bin/hubot --adapter slack >> /var/log/hubot.log 2>&1
end script
```

### hubot-scripts

Before hubot plugin packages were adopted, most plugins were held in the
[hubot-scripts][hubot-scripts] package. Some of these plugins have yet to be
migrated to their own packages. They can still be used but the setup is a bit
different.

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the `hubot-scripts.json` file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

### external-scripts

There will inevitably be functionality that everyone will want. Instead of
writing it yourself, you can use existing plugins.

Hubot is able to load plugins from third-party `npm` packages. This is the
recommended way to add functionality to your hubot. You can get a list of
available hubot plugins on [npmjs.com][npmjs] or by using `npm search`:

    % npm search hubot-scripts panda
    NAME             DESCRIPTION                        AUTHOR DATE       VERSION KEYWORDS
    hubot-pandapanda a hubot script for panda responses =missu 2014-11-30 0.9.2   hubot hubot-scripts panda
    ...


To use a package, check the package's documentation, but in general it is:

1. Use `npm install --save` to add the package to `package.json` and install it
2. Add the package name to `external-scripts.json` as a double quoted string

You can review `external-scripts.json` to see what is included by default.

##### Advanced Usage

It is also possible to define `external-scripts.json` as an object to
explicitly specify which scripts from a package should be included. The example
below, for example, will only activate two of the six available scripts inside
the `hubot-fun` plugin, but all four of those in `hubot-auto-deploy`.

```json
{
  "hubot-fun": [
    "crazy",
    "thanks"
  ],
  "hubot-auto-deploy": "*"
}
```

**Be aware that not all plugins support this usage and will typically fallback
to including all scripts.**

[npmjs]: https://www.npmjs.com
