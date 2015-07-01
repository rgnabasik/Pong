require 'rubygems'
require 'gosu'

class Ball
  attr_accessor :x, :y, :angle, :vel_x, :vel_y #allows for other classes to change these
  def initialize
    @image = @image3 = Gosu::Image.new("ball.bmp")
    @image2 = Gosu::Image.new("ball2.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0
  end
  
  def warp(x,y)
    @x, @y = x, y
  end
  
  def start #not sure I understand how the ball is moving
    @angle = rand(20..160)
    @vel_x = Gosu::offset_x(@angle,4)
    if rand(0.0..1.0) > 0.5 #not sure why this is here
      @vel_x *= -1
    end
    @vel_y = Gosu::offset_y(@angle,4)    
  end
  
  
  def move
    @x += @vel_x
    @y += @vel_y
    
    if @y > 585 || @y < 15 then #ball image is 30x30 pixels and we are using draw_rot so we need to take 15 away from the edges, bounces off top and bottom edges
      @vel_y *= -1
      @angle += 90
      @beep.play
    end
  end
  
  def draw
    if Gosu::button_down? Gosu::Kb1
      @image3 = @image
    elsif Gosu::button_down? Gosu::Kb2
      @image3 = @image2
    end
    @image3.draw_rot(@x,@y,1,0) #same ZOrder as the paddle
  end
end


class Player
  attr_reader :score
  def initialize
    @image = @image3 = Gosu::Image.new("paddle.bmp")
    @image2 = Gosu::Image.new("paddle2.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @score = 0
  end
  
  def warp(x,y)
    @x, @y = x,y
  end
  
  def move
    if Gosu::button_down? Gosu::KbUp 
      @vel_y = -5
    end
    if Gosu::button_down? Gosu::KbDown
      @vel_y = 5
    end
    
    @y += @vel_y  
    
    if @y < 87 || @y > 513
      if @y > 513
        @y = 513
      else
        @y = 87
      end
    end
    
    @vel_x *= 0.95 #should slow down the paddle when not pressing anything, basically a damping mechanism
    @vel_y *= 0.95    
  end
  
  def draw
    if Gosu::button_down? Gosu::Kb1 #normal
      @image3 = @image
    elsif Gosu::button_down? Gosu::Kb2 #mlg mode
      @image3 = @image2
    end
    @image3.draw_rot(@x,@y,1,0)
  end
  
  def collision(ball) #need to make sure we include the entire paddle
    if ball.x > 570
      if ball.y < @y + 88 and ball.y > @y - 88 then
        if ball.vel_x < 13
          ball.vel_x *= -1.1 #speeds up the ball if it is too slow
          ball.vel_y *= 1.1
        end
        #puts "#{ball.vel_x}    #{ball.vel_y}"
        @beep.play
      end
    end
  end
  
  def point(ball)
    if ball.x < 15 then
      @score += 1
      @beep.play
      ball.warp(300,300) #restarting the ball
      ball.start
    end
  end
end

class Opp
  attr_reader :score
  def initialize
    @image = @image3 = Gosu::Image.new("paddle.bmp")
    @image2 = Gosu::Image.new("paddle2.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @score = 0
  end
  
  def warp(x,y)
    @x, @y = x,y
  end
  
  def move(ball) #Opp AI
    if (@y-ball.y) > 0 #paddle above ball
      @vel_y = -2 #so move down
    else
      @vel_y = 2 #otherwise move up
    end
    
    @y += @vel_y
    
    if @y < 87 || @y > 513 #boundary conditions for the paddle
      if @y > 513
        @y = 513
      else
        @y = 87
      end
    end   
  end
  
  def draw
    if Gosu::button_down? Gosu::Kb1 #normal
      @image3 = @image
    elsif Gosu::button_down? Gosu::Kb2 #mlg mode
      @image3 = @image2
    end
    @image3.draw_rot(@x,@y,1,0)
  end
  
  def collision(ball) #need to make sure we include the entire paddle
    if ball.x < 30
      if ball.y < @y + 88 and ball.y > @y - 88 then
        if ball.vel_x < 13
          ball.vel_x *= -1.1 #speeds up the ball if it is too slow
          ball.vel_y *= 1.1
        end
        #puts "#{ball.vel_x}    #{ball.vel_y}"
        @beep.play
      end
    end
  end
  
  def point(ball)
    if ball.x > 585 then
      @score += 1
      @beep.play
      ball.warp(300,300) #restarting the ball
      ball.start
    end
  end
end

class GameWindow < Gosu::Window  #main game loop
  def initialize
    super 600, 600
    self.caption = "Pong me"
    
    @bg = @bg3 = Gosu::Image.new("bg.png", :tileable => true)
    @bg2 = Gosu::Image.new("bg2.png", :tileable => true)
    
    @player = Player.new
    @player.warp(590,300)
    
    @ball = Ball.new
    @ball.warp(300,300)
    @ball.start
    
    @opp = Opp.new
    @opp.warp(10,300)
    
    @font = Gosu::Font.new(20)
    @font2 = Gosu::Font.new(20)
    
    @win = Gosu::Font.new(60)
  end
  
  def update
    @player.move
    @ball.move
    @opp.move(@ball) 
    @player.point(@ball)
    @player.collision(@ball)
    @opp.point(@ball)
    @opp.collision(@ball)
    
  end
  
  def draw
    @player.draw
    @ball.draw
    @opp.draw
    if Gosu::button_down? Gosu::Kb1 #normal
      @bg3 = @bg
    elsif Gosu::button_down? Gosu::Kb2 #mlg mode
      @bg3 = @bg2
    end
    @bg3.draw(0,0,0)
    @font.draw("Score: #{@player.score}", 310, 10, 2, 1.0, 1.0, 0xff_ffff00)
    @font2.draw("Score: #{@opp.score}", 10, 10, 2, 1.0, 1.0, 0xff_ffff00)
    if @player.score == 5 then #win condition for player, no win condition for the AI
      @win.draw("The player wins!!!",100,300,2,1.0,1.0,0xff_ffff00)
      @ball.warp(300,300) #puts the ball in the center with no velocity
    end
  end
end

window = GameWindow.new
window.show

