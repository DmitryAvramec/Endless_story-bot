require 'telegram/bot'
require 'dotenv'
require 'sqlite3'
require 'yaml'
Dotenv.load
token = ENV["BOT_TOKEN"]

steps = YAML.load_file('./Story.yml')
HELLO =  <<-HELLOSTRING
Hello! I'm pretty young story bot
Usage:
      /story    - for start little story jorney
      /help     - this text
      /hi       - and i will say hello to you :)
HELLOSTRING

current_step =-1
$last_step = 3
$status = 0
check = false

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    send = lambda { |bot_message| bot.api.sendMessage(chat_id: message.chat.id, text: bot_message) }
    if !message.text.nil?
      unless check
        case message.text
        when "/start"
          send.(HELLO)
        when "/hi"
          send.("Hello, #{message.from.first_name}")
          send.("How do u doing?")
        when "/help"
          send.(HELLO)
        when "/story"
          current_step = 0
          check = true
          first_time = true
          send.("Готов к путешествию?")
          send.("Ай, кого я спрашиваю?! Прыгай в ступу! Земля, прощай!")
          send.("В добрый путь!")
        end
      else

        case  
        when message.text == steps[current_step]["right_answer"] 
          if current_step == steps.size
           $status = 1
          end 
          current_step += 1
        when message.text != steps[current_step]["right_answer"] 
          $status = 2   
        end

        case $status
        when 1
          send.("You done it! Congrats! Come back again :)")
          check = false 
          $status = 0
        when 2
          send.($steps[current_step]["fail"])
          send.("На этот раз не удалось =\\")
          check = false
          $status = 0
        end
      end

      if check
        send.(steps[current_step]["story"])
        send.("Выбери:")
        $steps[current_step]["answers"].each do |answer|
        send.(answer)
        end
        first_time = false
      end
    else
      send.("Моя твоя не понимай!")
      send.("'/help' попробуй ты набрать.")
    end
  end
end
