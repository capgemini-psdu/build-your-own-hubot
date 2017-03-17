# Scripts Detail

### PSD2obot Configuration

PSD2obot has been configured with scripts available at commit [ec0b06a][ec0b06a] from github [hubot-scripts][hubot-scripts] repository.

[ec0b06a]:https://github.com/github/hubot-scripts/commit/ec0b06aa9f2169c8427cdf77f49a0de698c969b1
[hubot-scripts]:https://github.com/github/hubot-scripts.git

Details for each of scripts can be found on the [hubot scripts catalogue][hubot-catalog].

[hubot-catalog]:http://hubot-script-catalog.herokuapp.com/

##### Excluded scripts:

The following scripts have been removed to seperate directory (excluded_scripts) due to error/warnings on startup.

  Additional Configuration Required:
    * aws.coffee - requires /config entries
    * fastspring.coffee:  privateKey = process.env.HUBOT_FASTSPRING_PRIVATE_KEY
    * file-brain.coffee Error: ENOENT: no such file or directory, open '/var/hubot/brain-dump.json'
    * gerrit.coffee Gerrit commands inactive because HUBOT_GERRIT_SSH_URL= is not a valid SSH URL
    * gtalk.coffee TypeError: Cannot read property 'domain' of undefined
    * harvest.coffee HUBOT_HARVEST_SUBDOMAIN in the environment to use the harvest plugin script
    * janky.coffee TypeError: Parameter "url" must be a string, not undefined
    * jira-issues.coffee TypeError: Cannot read property 'length' of null
    * mongo-brain.coffee requires mongodb instance
    * mongolab-brain.coffee TypeError: Parameter "url" must be a string, not undefined
    * pg-brain.coffee: Error: pg-brain requires a DATABASE_URL to be set
    * quandora.coffee no domain defined, you need to set HUBOT_QUANDORA_DOMAIN
    * s3-brain.coffee: Error: S3 brain requires HUBOT_S3_BRAIN_ACCESS_KEY_ID, HUBOT_S3_BRAIN_SECRET_ACCESS_KEY and HUBOT_S3_BRAIN_BUCKET configured
    * turntable.coffee TT_AUTH, TT_USERID, TT_ROOMID and TT_CHAN environment variables to enable the turntable.fm script
    * tweet.coffee: HUBOT_TWITTER_* environment vairables are required.
    * tweeter.coffee: HUBOT_TWITTER_* environment vairables are required.
    * twitter-content.coffee: HUBOT_TWITTER_* environment vairables are required.
    * twitter.coffee: HUBOT_TWITTER_* environment vairables are required.
    * twitter-mention.coffee: HUBOT_TWITTER_* environment vairables are required.
    * walkie.coffee - Walkie: configs are not set

  Error:
    * beeradvocate.coffee script does not work (github/hubot-scripts#1436)
    * drush.coffee - ERROR Error: spawn drush ENOENT
    * pagerduty_points.coffee: SyntaxError: unexpected OUTDENT
    * stocks.coffee: ReferenceError: modules is not defined
    * yelp.coffee: TypeError: require(...).createClient is not a function
    Unable to load Error
      * bing-images.coffee undefined
      * espn.coffee: undefined
      * team-city-listener.coffee: undefined

  Warning:
    * crossing.coffee - Gets border waiting times to US - depreciated documentaion syntax
    * dimmerworld.coffee Anchors don't work well with respond, perhaps you want to use 'hear' - The regex in question was /^dimmer/i
    * plus_one.coffee is using deprecated documentation syntax
    * trollicon.coffee is using deprecated documentation syntax

  Invesigation required:
    * eval.coffee - stops on INFO Brain received eval language list
    * talkative.coffee - stops on 'loading knowledge'
    * webshot.coffee - Failed at the hashlib@1.0.1 preinstall script 'node-waf clean || true; node-waf configure build'.
      module hashlib 1.0.1 fails to compile on Mac. May work on other OS?

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
