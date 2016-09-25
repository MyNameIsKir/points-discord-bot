require 'discordrb'
require 'yaml'

credentials = YAML.load_file "credentials.yaml"
user_points = (YAML.load_file("users.yaml") or {})

bot = Discordrb::Bot.new token: credentials["token"], application_id: credentials["client_id"]

def save_to_file(user_points)
  File.open('users.yaml', 'w') {|f| f.write user_points.to_yaml }
end

bot.mention(contains: /help/i) do |event|
  event.respond "Hey #{event.author.name}, need help? Cool, using me is simple.\n\n"\
    "-To reward or dock points, send a message starting with a tag with your target user, then end that message with either ``++`` or ``--``.\n"\
    "-If you want to see points for specific user(s), simply ping me, with ``show points`` and tags for all of the users you wish to see points for.\n"\
    "-To show the leaderboard, ping me with ``show leaderboard``."
end

bot.message(contains: /\A<@!?\d{1,}>.*\+{2}\z/) do |event|
  response = ""
  event.message.mentions.each do |user|
    user_points[user.id] ? user_points[user.id] += 1 : user_points[user.id] = 1
    response += "#{user.name} now has #{user_points[user.id]} point(s).\n"
  end
  event.respond response
  save_to_file(user_points)
end

bot.message(contains: /\A<@!?\d{1,}>.*\-{2}\z/) do |event|
  response = ""
  event.message.mentions.each do |user|
    user_points[user.id] ? user_points[user.id] -= 1 : user_points[user.id] = -1
    response += "#{user.name} now has #{user_points[user.id]} point(s).\n"
  end
  event.respond response
  save_to_file(user_points)
end

bot.mention(from: "MyNameIsKir", contains: /set points/i) do |event|
  response = ""
  points = event.content.match(/points=\d{1,}/)[0].gsub(/points=/, "").to_i
  event.message.mentions.each do |user|
    if !user.current_bot?
      user_points[user.id] = points
      response += "#{user.name} now has #{user_points[user.id]} point(s).\n"
    end
  end
  event.respond response
  save_to_file(user_points)
end

bot.mention(contains: /show leaderboard/i) do |event|
  response = ""
  leaderboard = user_points.sort_by {|_key, value| value}
  (0..4).each {|i|  response += "##{i + 1}.) #{bot.users[leaderboard[i][0]].name}: #{leaderboard[i][1]} point(s)\n" if leaderboard[i]}
  event.respond response
  save_to_file(user_points)
end

bot.mention(contains: /show points/i) do |event|
  response = ""
  event.message.mentions.each {|user| response += "#{user.name} has #{user_points[user.id]} point(s).\n" if !user.current_bot?}
  event.respond response
end

bot.run