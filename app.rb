require 'selenium-webdriver'
require 'json'

class InstaBot
    attr_reader :username, :password

    def initialize filename
        file = File.read(filename)
        data_hash = JSON.parse(file) 
        @username = data_hash["username"]
        @password = data_hash["password"]
        @driver = Selenium::WebDriver.for :firefox
        @wait = Selenium::WebDriver::Wait.new(timeout: 5) 
    end

    def login
        bot = @driver

        # Log in to instagram
        bot.navigate.to 'https://www.instagram.com/accounts/login'
        element = @wait.until { bot.find_element(name: 'username') }
        element.send_keys @username
        element = @wait.until {bot.find_element(name: 'password') }
        element.send_keys @password
        element.submit

        # Click away from pop-up
        element = @wait.until {bot.find_element(class: 'HoLwm')}
        element.click
    end

    def like_posts search_term
        bot = @driver
        _loop = 5
        loop do
            bot.get('https://www.instagram.com/explore/tags/'+ search_term + '/')
            _loop.times do 
                bot.execute_script 'window.scrollTo(0, document.body.scrollHeight)'
                sleep 1
            end
            _loop += 5
            posts = @wait.until { bot.find_elements(class: '_bz0w') }
            links = posts.map{ |e| e.find_element(xpath: "./*").property("href")}
            links.reverse.each do |link|
                bot.get link
                post = @wait.until { bot.find_element(class: 'afkep').find_element(xpath: './*').attribute("aria-label") }
                p (post == "Unlike") ? "Already liked" : "Liking post"
                break if post == "Unlike"
                bot.find_element(class: 'afkep').click
            end
        end
    end
end

query = gets.chomp
bot = InstaBot.new "config.json"
bot.login
bot.like_posts query
