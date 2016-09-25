require 'discordrb'
require 'yaml'

credentials = YAML.load_file "credentials.yaml"
user_points = (YAML.load_file("users.yaml") or {})

bot = Discordrb::Bot.new token: credentials["token"], application_id: credentials["client_id"]

bot.message(contains: /\A<@!?\d{1,}>.*\+{2}\z/) do |event|
  referenced_user = bot.users[event.content.match(/\A<@!?\d{1,}>/)[0].gsub(/\D/, "").to_i]
  user_points[referenced_user.id] ? user_points[referenced_user.id] += 1 : user_points[referenced_user.id] = 1
  event.respond "#{referenced_user.name} now has #{user_points[referenced_user.id]} point(s)."
  File.open('users.yaml', 'w') {|f| f.write user_points.to_yaml }
end

bot.message(contains: /\A<@!?\d{1,}>.*\-{2}\z/) do |event|
  referenced_user = bot.users[event.content.match(/\A<@!?\d{1,}>/)[0].gsub(/\D/, "").to_i]
  user_points[referenced_user.id] ? user_points[referenced_user.id] -= 1 : user_points[referenced_user.id] = -1
  event.respond "#{referenced_user.name} now has #{user_points[referenced_user.id]} point(s)."
  File.open('users.yaml', 'w') {|f| f.write user_points.to_yaml }
end

bot.mention(contains: /(h|H)(e|E)(l|L)(p|P)/) do |event|
  event.respond "Hey #{event.author.name}, need help? Cool, using me is simple.\n\nSimply send a message starting with a user you wish to reward or dock points from, then end that message with either \"++\" or \"--\"."
end

bot.run