#require 'rubygems'
require './heap.rb'

class Position
	include Comparable
	attr_reader :x, :y  

	def initialize(x,y)
		@x, @y = x,y
	end

	def <=>(another)
		return 0 if another.x == @x && another.y == @y
		return 1
	end

	def man_distance(point)
		(point.x - @x).abs + (point.y - @y).abs 
	end

	def neighbours(row_limit, column_limit)
		neighbours = []
		if @x > 0
			neighbours << Position.new(@x-1, @y)
		end
		if @x < row_limit - 1
			neighbours << Position.new(@x+1, @y)
		end
		if @y > 0
			neighbours << Position.new(@x, @y-1)
		end
		if @y < column_limit - 1
			neighbours << Position.new(@x, @y+1)
		end
		return neighbours
	end

	def hash_key
		"x:#{@x}y:#{@y}"
	end

	def inspect
		"x: #{@x}, y: #{@y}"
	end
end

class Node
	include Comparable
	attr_accessor :position, :heuristic, :distance, :parent

	def initialize(position=nil, heuristic=0, distance=0, parent=nil)
		@position, @heuristic, @distance, @parent = position, heuristic, distance, parent
	end

	def <=>(another)
		return nil if another == nil
		return 0 if another.position == @position
		return 1
	end

	def inspect
		"Position:#{position.inspect}, Cost:#{self.cost}, Heuristic:#{self.heuristic}, Distance:#{self.distance}"
	end

	def cost
		@heuristic + @distance
	end

	def print_path
		if self.parent == nil
			puts "#{self.position.inspect}, Cost so far = #{self.distance}"
		else
			self.parent.print_path
			puts "#{self.position.inspect}, Cost so far = #{self.distance}"
		end
	end

	def array_path(path)
		if self.parent == nil
			return path << self
		else
			return self.parent.array_path(path) << self
		end
	end
end

class A_star

	def initialize(map, weights)
		@map, @weights = map, weights
		@rows, @columns = map.length, map[0].length
		@heap = Containers::MinHeap.new
		map.each_with_index do |line, index|
			start_column = line.index("S")
			goal_column = line.index("G")
			if start_column != nil
				@start = Node.new(Position.new(index, start_column), 0, 0, nil)
			end
			if goal_column != nil
				@goal = Position.new(index, goal_column)
			end
		end
		@start.heuristic = @start.position.man_distance(@goal)
	end

	def run
		visited = Hash.new(false)
		@heap.push(@start.cost, @start)
		while (node = @heap.pop) && node.position != @goal
			next if visited[node.position.hash_key]
			neighbours = node.position.neighbours(@rows, @columns)
			neighbours.each do |position|
				new_node = Node.new
				new_node.position = position
				new_node.parent = node
				new_node.heuristic = position.man_distance(@goal)
				new_node.distance = node.distance + @weights[@map[position.x][position.y]]
				@heap.push(new_node.cost, new_node)
			end
			visited[node.position.hash_key] = true
		end
		return node.array_path([])
	end

end

# map = []
# f = File.open("map.txt", "r")
# f.each_line do |line|
#   	map << line.gsub("\n", "")
# end
# f.close

# weights = {}
# f = File.open("weights.txt", "r")
# f.each_line do |line|
# 	key, value = line.gsub("\n", "").split(":")
# 	weights[key] = value.to_i
# end
# f.close


# a_star = A_star.new(map, weights)
# answer = a_star.run
# puts "answer: #{answer.last.inspect}"
# answer.each do |node|
# 	puts node.inspect
# end
