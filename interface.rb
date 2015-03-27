require './grafo.rb'
require 'Benchmark'

class Hero
	attr_accessor :x, :y, :image

	def initialize(app, x, y, width, height)
		@app = app
		@x, @y, @width, @height = x, y, width, height
	end

	def draw
		@image = @app.image(
		"seya.png",
		top: @y*@height,
		left: @x*@width,
		width: @width,
		height: @height)
	end

	def move(direction)
		case direction
     	when :up
     		@y -= 1
     	when :down
     		@y += 1
    	when :left
     		@x -= 1
    	when :right
    		@x += 1
    	end
		
		if @x < 0
			@x = 0
		end
		if @y < 0
			@y = 0
		end
		self.remove
		self.draw
	end

	def remove
		@image.remove
	end
end

width = 42*18 + 200
map_width = 42*18
height = 42*18

Shoes.app(title:"A* - Cavaleiros do Zodíaco", width:(width), height:(height), resizable: false) do
	map = []
	f = File.open("map.txt", "r")
	f.each_line do |line|
  		map << line.gsub("\n", "")
	end
	f.close
	weights = {}
	f = File.open("weights.txt", "r")
	f.each_line do |line|
		key, value = line.gsub("\n", "").split(":")
		weights[key] = value.to_i
	end
	f.close
	a_star = A_star.new(map, weights)
	answer = []
	time = Benchmark.measure do
		answer = a_star.run
	end
	rect_width  = map_width/map[0].length
	rect_height = height/map.length
	x = 0
	y = 0
	start_position = {}
	map.each_with_index do |row, row_number|
		row.split("").each_with_index do |color, column_number|
			case color
			when "M"
				fill black
			when "S"
				start_position[:x] = row_number
				start_position[:y] = column_number
				fill red
			when "G"
				fill green
			when "P"
				fill darkgray
			else
				fill gray
			end
			rect(x, y, rect_width, rect_height)
			x += rect_width
		end
		x = 0
		y += rect_height
	end
	@hero = Hero.new(self, start_position[:x], start_position[:y], rect_width, rect_height)
	@hero.draw
	stack(top: 0, left: map_width, width: (width - map_width)) {
		para "Trabalho 1 IA"
		@cost = para "Starting"
		@heuristic = para ""
		para "Tempo do A*: #{time.real}"
	}
	keypress do |k|
		answer.shift
   	end
   	#pid = fork{ exec 'mpg123','-q', "./musica.m4a" }
	animate(24) do
		node = answer.shift
		if node
			@hero.remove
			@hero.x = node.position.y
			@hero.y = node.position.x
			@cost.replace "Distance: #{node.distance}"
			@heuristic.replace "Heuristic: #{node.heuristic}"
			@hero.draw
		end
	end
end

