require 'telegram/bot'
require 'sqlite3'
$token = "413768384:AAET1KjKSg5kgO-gvs4bxcvnkNRPNkZa1yg"

step_1 = {
  story: " -Смотри! Голуби как высоко-то летают...\n Сказать что это не голуби?",
  answers: ["Да", "Хорошо летят же, зачем тревожить"],
  right_answer: "Да",
  fail: "Дракончики догнали тебя и немножко съели =("
}
step_2 = {
  story: "Вы приземлились на полянке. \n-Ух! Еле отвязались от них. Кушать будешь?",
  answers: ["Да", "Нет"],
  right_answer: "Да",
  fail: "Брезгуешь значит? Шахалай махалай зверем будешь так и знай!\n\nТеперь ты зверушка"
}
step_3 = {
  story: "Ну, вот и перекусили. Чего нужно-то от меня?",
  answers: ["Сказку", "Самогону конечно же!"],
  right_answer: "Сказку",
  fail: ".........\n\nПрошул день\n-Wakeup Neo!"
}
step_4 = {
  story: "Сказка будет, когда бд прицепит 1 Неуч!!!!",
  answers: ["Эх", "Чего это он неуч? Он почти молодец ))))"],
  right_answer: "Эх",
  fail: "Не все считают так же! Скалкой в плечи и ты полетел"
}
$steps = [step_1, step_2, step_3, step_4]

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




Telegram::Bot::Client.run($token) do |bot|
  bot.listen do |message|
    send = lambda { |bot_message| bot.api.sendMessage(chat_id: message.chat.id, text: bot_message) }
    if !message.text.nil?
      unless check
        case
        when message.text.start_with?("/start")
          send.(HELLO)
        when message.text.start_with?("/hi")
          send.("Hello, #{message.from.first_name}")
          send.("How do u doing?")
        when message.text.start_with?("/help")
          send.(HELLO)
        when message.text.start_with?("/story")
          current_step = 0
          check = true
          first_time = true
          send.("Print 'Yes' if u want start our jorney")
          send.("Ай, кого я спрашиваю?! Прыгай в ступу! Земля, прощай!")
          send.("В добрый путь!")
        end
      else
        puts " +++++++++++++++ "
        case  
        when message.text == $steps[current_step][:right_answer] 
          if current_step == $last_step
           $status = 1
          end 
          current_step += 1
        when message.text != $steps[current_step][:right_answer] 
          $status = 2   
        end

      puts "!!!!!!!!!!!!!"
        case $status
        when 1
          send.("You done it! Congrats! Come back again :)")
          check = false 
          $status = 0
        when 2
          send.($steps[current_step][:fail])
          send.("На этот раз не удалось =\\")
          check = false
          $status = 0
        end
      end

      if check
        
        send.($steps[current_step][:story])
        send.("Выбери:")
        $steps[current_step][:answers].each do |answer|
          send.(answer)
        end
        first_time = false
      end
    else
      send.("Моя твоя не понимай!")
      send.("'/help' попробуй ты набрать, дабы узнать предел моего величия.")
    end
  end
end
