require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :id, :name, :grade

def initialize(id = nil, name, grade)
  @id = id
  @name = name
  @grade = grade
end

# def initialize(hash = {})
#   @id = hash['id']
#   @name = hash['name']
#   @grade = hash['grade']
# end

def self.new_from_db(row)


  # create a new Student object given a row from the database
  Student.new(id = row[0], name = row[1], grade = row[2])
end

def self.all
  sql = <<-SQL
        SELECT * FROM students
        SQL
  students = DB[:conn].execute(sql)
  students.map do |student|
    self.new_from_db(student)
  end
  # retrieve all the rows from the "Students" database
  # remember each row should be a new instance of the Student class
end


def self.find_by_name(name)
  sql = <<-SQL
        SELECT * FROM students WHERE name = name
        SQL
   result = DB[:conn].execute(sql).flatten
   self.new_from_db(result)

  # find the student in the database given a name
  # return a new instance of the Student class
end

def save
  if !self.id
  sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.grade)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  else
  update = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = '#{self.id}'
    SQL
    DB[:conn].execute(update, self.name, self.grade)
  end
end

def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade TEXT
  )
  SQL

  DB[:conn].execute(sql)
end

def self.drop_table
  sql = "DROP TABLE IF EXISTS students"
  DB[:conn].execute(sql)
end


  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def self.create(name, grade)
    new_instance = self.new(name, grade)
    new_instance.save
  end

  def update
    sql = <<-SQL
    UPDATE students
    set name = ?, grade = ?
    WHERE id = '#{self.id}'
    DB[:conn].execute(sql, self.name, self.grade)
    SQL
  end


end
