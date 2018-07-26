# Description:
#   Commands for interacting with AMOS
#
# Dependancies:
#
# Configuration:
#   HUBOT_COMPOSE_AUTH set the basic auth for accessModes
#
# Commands:
#   hubot AMOS set server <server name> - configure the compose server
#   hubot AMOS set serverauth - store authentication digest for the server
#   hubot AMOS status - queries the configured server status
#   hubot AMOS list server - lists the configured server
#
# Notes:
#
# Author:
#   Nick Jupp (nick@jupps.com)
#


module.exports = (robot) ->
  # list the status with the /v1/server/up/extended call
  robot.respond /AMOS namespaces/i, (msg) ->
    robot.logger.info("AMOS: namespaces called")
    url = robot.brain.get 'amos_serverurl'
    api = "/oapi/v1/net"
    auth = "Bearer #{robot.brain.get 'amos_auth'}"
    msg.http(url + api)
      .header('Authorization', auth)
      .get() (err, res, body) ->
      # err & response status checking code here
      # your code here
        data=JSON.parse body

        for key, value of data
          msg.send "#{key} - #{value}"

  # add configuration for the active server to the hubot datastore
  robot.respond /AMOS set server (.*)/i, (res)->
    robot.logger.info("AMOS: set server called")
    server =res.match[1]
    serverurl = "https://#{server}.amosdemo.io:8443"
    res.reply "Adding #{server} to the brain as #{serverurl}"
    robot.brain.set 'amos_server', server
    robot.brain.set 'amos_serverurl', serverurl
    robot.logger.info("AMOS: server set to #{server}")

  # add configuration for the active server authentication to the hubot datastore
  robot.respond /AMOS set serverauth (.*)/i, (res)->
    robot.logger.info("AMOS: set serverauth called")
    amos_auth =res.match[1]
    res.reply "Thanks! Added authentication details to the brain"
    robot.brain.set 'amos_auth', amos_auth
    robot.logger.info("AMOS: auth stored")

  # list the configuration of the active server from the datastore
  robot.respond /AMOS list server/i, (res)->
    robot.logger.info("AMOS: list server called")
    server = robot.brain.get 'amos_server'
    serverurl = robot.brain.get 'amos_serverurl'
    serverauth = robot.brain.get 'amos_auth'
    res.reply "The configured server is *#{server}* at #{serverurl}\nThe authentication digest is _#{serverauth}_"
