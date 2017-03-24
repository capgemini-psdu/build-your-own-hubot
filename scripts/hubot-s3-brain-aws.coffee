# Description:
#   Stores the brain in Amazon S3.
#
# Configuration:
#   HUBOT_S3_BRAIN_BUCKET             - Bucket to store brain in
#   HUBOT_S3_BRAIN_FILE_PATH          - [Optional] Path/File in bucket to store brain at
#   HUBOT_S3_BRAIN_SAVE_INTERVAL      - [Optional] auto-save interval in seconds
#   HUBOT_S3_BUCKET_NOT_REQUIRED      - [Optional] Bucket required flag
#
# Commands:
#
# Notes:
#   Updated version of github.com/github/hubot-scripts/s3-brain.coffee by *IrishStyle*
#   Changes to remove creds as per comment on dylanmei version:
#       https://github.com/dylanmei/hubot-s3-brain/issues/1
#
#   Take care if using this brain storage with other brain storages.  Others may
#   set the auto-save interval to an undesireable value.  Since S3 requests have
#   an associated monetary value, this script uses a 30 minute auto-save timer
#   by default to reduce cost.
#
# Credentials from IAM Roles for EC2 Instances:
#
#   If you are running your application on Amazon EC2, you can leverage EC2's IAM roles
#   functionality in order to have credentials automatically provided to the instance.
#
#   If you have configured your instance to use IAM roles, the SDK will automatically
#   select these credentials for use in your application, and you do not need to
#   manually provide credentials in any other format.

util = require 'util'
AWS  = require 'aws-sdk'

AWS.config.apiVersions = {
  s3: '2006-03-01'
}

module.exports = (robot) ->

  loaded            = false
  bucket            = process.env.HUBOT_S3_BRAIN_BUCKET
  file_path         = process.env.HUBOT_S3_BRAIN_FILE_PATH || "brain-dump.json"
  # default to 30 minutes (in seconds)
  save_interval     = process.env.HUBOT_S3_BRAIN_SAVE_INTERVAL || 30 * 60
  not_required      = process.env.HUBOT_S3_BUCKET_NOT_REQUIRED

  if !bucket
    if not_required
      robot.logger.warning "S3 brain requires HUBOT_S3_BRAIN_BUCKET configured, will not persist"
    else
      throw new Error('S3 brain requires HUBOT_S3_BRAIN_BUCKET configured')

  save_interval = parseInt(save_interval)
  if isNaN(save_interval)
    throw new Error('HUBOT_S3_BRAIN_SAVE_INTERVAL must be an integer')

  s3 = new AWS.S3({params: {Bucket: bucket, Key: file_path}})

  store_brain = (brain_data, callback) ->
    if !loaded
      robot.logger.debug 'Not saving to S3, because not loaded yet'
      return

    params = {
      Body: JSON.stringify(brain_data),
    }
    s3.putObject params, (err, data) ->
      if err
        robot.logger.error util.inspect(err)
      else if data
        robot.logger.debug "Saved brain to s3://#{bucket}/#{file_path}"

      if callback then callback(err, data)

  store_current_brain = () ->
    store_brain robot.brain.data

  s3.getObject {}, (err, data) ->
    if err
      if err.statusCode == 404
        robot.logger.info "No brain found at s3://#{bucket}/#{file_path}"
        robot.brain.mergeData {}
        loaded = true
      else if not_required
        robot.logger.info "Unable to contact S3, will not persist"
      else
        robot.logger.error "Error contacting S3:\n#{util.inspect(err)}"
        process.exit(1)

    if data && data.Body
      robot.logger.debug "Found brain at s3://#{bucket}/#{file_path}"
      robot.brain.mergeData JSON.parse(data.Body)
      loaded = true

    robot.brain.resetSaveInterval(save_interval)

  robot.brain.on 'save', () ->
    store_current_brain()

  robot.brain.on 'close', ->
    store_current_brain()
