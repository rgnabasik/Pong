require 'rubygems'
require 'gosu'

class Ball
  attr_accessor :x, :y, :angle, :vel_x, :vel_y #allows for other classes to change these
  def initialize
    @image = Gosu::Image.new("ball.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0
  end
  
  def warp(x,y)
    @x, @y = x, y
  end
  
  def start #not sure I understand how the ball is moving
    @angle = rand(360)
    @vel_x = Gosu::offset_x(@angle,2)
    @vel_y = Gosu::offset_y(@angle,2)    
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    
    if @y > 585 || @y < 15 then #ball image is 30x30 pixels and we are using draw_rot so we need to take 15 away from the edges
      @vel_y *= -1
      @angle += 90
      @beep.play
    end
  end
  
  def draw
    @image.draw_rot(@x,@y,1,0) #same ZOrder as the paddle
  end
end


class Player
  attr_reader :score
  def initialize
    @image = Gosu::Image.new("paddle.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @score = 0
  end
  
  def warp(x,y)
    @x, @y = x,y
  end
  
  def move_up
    @vel_y += Gosu::offset_y(0,0.5)
  end
  
  def move_down
    @vel_y -= Gosu::offset_y(0,0.5)
  end
  
  def move
    @x += @vel_x #obviously should not be moving in the x direction but might add something later on
    @y += @vel_y
    @x %= 600    #allows for the player to wrap around the game screen
    @y %= 600
    
    @vel_x *= 0.95 #should slow down the paddle when not pressing anything, basically a damping mechanism
    @vel_y *= 0.95    
  end
  
  def draw
    @image.draw_rot(@x,@y,1,0)
  end
  
  def collision(ball) #need to make sure we include the entire paddle
    if ball.x > 570
      if ball.y < @y + 88 and ball.y > @y - 88 then
        ball.vel_x *= -1
        ball.vel_y *= -1
        ball.angle += 90 #maybe try to add some velocity to the ball depending on the speed of the paddle
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
    @image = Gosu::Image.new("paddle.bmp")
    @beep = Gosu::Sample.new("Beep.wav")
    @x = @y = @vel_x = @vel_y = @score = 0
  end
  
  def warp(x,y)
    @x, @y = x,y
  end
  
  def move_up(ball)
    @vel_y += Gosu::offset_y(0,0.5)
  end
  
  def move_down(ball)
     @vel_y -= Gosu::offset_y(0,0.5)
  end
  
  def move(ball)
    @x += @vel_x #obviously should not be moving in the x direction but might add something later on
    @y += @vel_y
    @x %= 600    #allows for the player to wrap around the game screen
    @y %= 600
    
    @vel_x *= 0.95 #should slow down the paddle when not pressing anything, basically a damping mechanism
    @vel_y *= 0.95    
  end
  
  def draw
    @image.draw_rot(@x,@y,1,0)
  end
  
  def collision(ball) #need to make sure we include the entire paddle
    if ball.x < 30
      if ball.y < @y + 88 and ball.y > @y - 88 then
        ball.vel_x *= -1
        ball.vel_y *= -1
        ball.angle += 90 #maybe try to add some velocity to the ball depending on the speed of the paddle
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
    
    @bg = Gosu::Image.new("bg.png", :tileable => true)
    
    @player = Player.new
    @player.warp(590,300)
    
    @ball = Ball.new
    @ball.warp(300,300)
    @ball.start
    
    @opp = Opp.new
    @opp.warp(10,300)
    
    @font = Gosu::Font.new(20)
    @font2 = Gosu::Font.new(20)
  end
  
  def update
    if Gosu::button_down? Gosu::KbUp then
      @player.move_up
    end
    if Gosu::button_down? Gosu::KbDown
      @player.move_down
    end
    @player.move
    @ball.move
    @opp.move
    @player.point(@ball)
    @player.collision(@ball)
    @opp.point(@ball)
    @opp.collision(@ball)
    
  end
  
  def draw
    @player.draw
    @ball.draw
    @opp.draw
    @bg.draw(0,0,0)
    @font.draw("Score: #{@player.score}", 310, 10, 2, 1.0, 1.0, 0xff_ffff00)
    @font2.draw("Score: #{@opp.score}", 10, 10, 2, 1.0, 1.0, 0xff_ffff00)
  end
end

window = GameWindow.new
window.show

