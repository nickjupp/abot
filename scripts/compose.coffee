# Description:
#   Commands for interacting with Compose
#
# Dependancies:
#
# Configuration:
#   HUBOT_COMPOSE_AUTH set the basic auth for accessModes
#
# Commands:
#   hubot compose set server <server name> - configure the compose server
#   hubot compose set serverauth - store authentication digest for the server
#   hubot compose status - queries the configured server status
#   hubot compose list server - lists the configured server
#
# Notes:
#
# Author:
#   Nick Jupp (nick@jupps.com)
#


module.exports = (robot) ->
  # list the status with the /v1/server/up/extended call
  robot.respond /compose status/i, (msg) ->
    robot.logger.info("compose: status called")
    url = robot.brain.get 'serverurl'
    api = "/v1/server/up/extended"
    auth = "Basic #{robot.brain.get 'auth'}"
    msg.http(url + api)
      .header('Authorization', auth)
      .get() (err, res, body) ->
      # err & response status checking code here
      # your code here
        data=JSON.parse body
        msg.send "Compose says \nServer up: *#{data.up}*\n"

        for key, value of data
          msg.send "#{key} - #{value}"

  # add configuration for the active server to the hubot datastore
  robot.respond /compose set server (.*)/i, (res)->
    robot.logger.info("compose: set server called")
    server =res.match[1]
    serverurl = "https://#{server}.canopy-cloud.com"
    res.reply "Adding #{server} to the brain as #{serverurl}"
    robot.brain.set 'server', server
    robot.brain.set 'serverurl', serverurl
    robot.logger.info("compose: server set to #{server}")

  # add configuration for the active server authentication to the hubot datastore
  robot.respond /compose set serverauth (.*)/i, (res)->
    robot.logger.info("compose: set serverauth called")
    auth =res.match[1]
    res.reply "Thanks! Added authentication details to the brain"
    robot.brain.set 'auth', auth
    robot.logger.info("compose: auth stored")

  # list the configuration of the active server from the datastore
  robot.respond /compose list server/i, (res)->
    robot.logger.info("compose: list server called")
    server = robot.brain.get 'server'
    serverurl = robot.brain.get 'serverurl'
    serverauth = robot.brain.get 'auth'
    res.reply "The configured server is *#{server}* at #{serverurl}\nThe authentication digest is _#{serverauth}_"

  # get applications with v1/applications
  robot.respond /compose list applications/i, (msg)->
    robot.logger.info("compose: list applications called")
    url = robot.brain.get 'serverurl'
    api = "/v1/applications"
    auth = "Basic #{robot.brain.get 'auth'}"
    msg.http(url + api)
      .header('Authorization', auth)
      .get() (err, res, body) ->
      # err & response status checking code here
      # your code here
        data=JSON.parse body
        count=Object.keys(data).length

      #  msg.send "*#{count} applications running*"


        msg.send({
            "text": "Running apps",
            "attachments": [
                {
                    "text": "There are #{count} applications running. Would you like to list them?",
                    "fallback": "You are unable to do this",
                    "callback_id": "list_apps",
                    "color": "#3AA3E3",
                    "attachment_type": "default",
                    "actions": [
                        {
                            "name": "list",
                            "text": "Yes",
                            "type": "button",
                            "value": "yes"
                        },

                    ]
                }
            ]
        })





        for key, value of data
          status = value.status

          colour = "#D3D3D3"
          if status == "ERROR" then colour = "danger"
          else if status == "RUNNING" then colour = "good"
          else if status == ("STARTING" or "STOPPING") then colour = "warning"

          msg.send({
                  attachments: [{
                      color: colour,
                      fields: [
                        {
                          title: value.spec.name,
                          value: value.status
                          short: false
                        }
                      ]
                  }],
              })
