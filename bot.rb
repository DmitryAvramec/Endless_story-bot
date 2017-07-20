require 'telegram/bot'
require 'dotenv'
require 'yaml'
Dotenv.load
TOKEN = ENV["BOT_TOKEN"]

STEPS = YAML.load_file('./story.yml')
HELLO =  <<-HELLOSTRING
Hello! I'm pretty young story bot
Usage:
      /story    - for start little story jorney
      /help     - this text
      /hi       - and i will say hello to you :)
HELLOSTRING

CURENT_STEP =-1
STATUS = 0
CHECK = false

Telegram::Bot::Client.run(TOKEN) do |bot|
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
          CURENT_STEP = 0
          CHECK = true
          first_time = true
          send.("Готов к путешествию?")
          send.("Ай, кого я спрашиваю?! Прыгай в ступу! Земля, прощай!")
          send.("В добрый путь!")
        end
      else

        case  
        when message.text == STEPS[current_step]["right_answer"] 
          if CURENT_STEP == STEPS.size
           STATUS = 1
          end 
          CURENT_STEP += 1
        when message.text != STEPS[current_step]["right_answer"] 
          STATUS = 2   
        end

        case STATUS
        when 1
          send.("You done it! Congrats! Come back again :)")
          CHECK = false 
          STATUS = 0
        when 2
          send.(STEPS[current_step]["fail"])
          send.("На этот раз не удалось =\\")
          CHECK= false
          STATUS = 0
        end
      end

      if check
        send.(STEPS[CURENT_STEP]["story"])
        send.("Выбери:")
        answers = STEPS[CURENT_STEP]["answers"]
        answers.each do |answer|
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
