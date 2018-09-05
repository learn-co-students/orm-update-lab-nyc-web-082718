require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTERGER
    )"
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end


  def self.create(name, grade)
    self.new(name, grade).save
  end


  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end


  def self.new_from_db(array)
    self.new(array[1], array[2], array[0])
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    student = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student)
  end


  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
