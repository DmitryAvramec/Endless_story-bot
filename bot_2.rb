require 'telegram/bot'
require 'dotenv'
require 'yaml'
Dotenv.load
token = ENV["BOT_TOKEN"]
STEPS = YAML.load_file('./story.yml')
HELLO =  <<-HELLOSTRING
Hello! I'm pretty young story bot
Usage:
      /story    - for start little story jorney
      /help     - this text
      /hi       - and i will say hello to you :)
HELLOSTRING

current_step =0
status = 0
check = false

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    send = lambda { |bot_message| bot.api.sendMessage(chat_id: message.from.id, text: bot_message) }
    send_l = lambda { |bot_message, markup| bot.api.send_message(chat_id: message.from.id, text: bot_message, reply_markup: markup) }      
    unless message.nil?
      case 
      when message.is_a?(Telegram::Bot::Types::CallbackQuery)
        if message.data != STEPS[current_step]["right_answer"]
          status = 2
        end
        if message.data == STEPS[current_step]["right_answer"]
          status = 1 if current_step == STEPS.size - 1
          current_step += 1  
        end
      when message.is_a?(Telegram::Bot::Types::Message)
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
          send.("Готов к путешествию?")
          send.("Ай, кого я спрашиваю?! Прыгай в ступу! Земля, прощай!")
          send.("В добрый путь!")
        else
          send.("Моя твоя не понимай!")
          send.("'/help' попробуй ты набрать, дабы узнать предел моего величия.")
        end
      end

      case status
      when 1
        send.("You done it! Congrats! Come back again :)")
        check = false 
        status = 0
      when 2
        send.(STEPS[current_step]["fail"])
        send.("На этот раз не удалось =\\")
        check = false
        status = 0
      end
    
      if check
        send.(STEPS[current_step]["story"])
        kb = []
        STEPS[current_step]["answers"].each do |answer|
          kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: answer, callback_data: answer)
        end
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        send_l.('Выбери: ', markup)
      end
    end
  end
end