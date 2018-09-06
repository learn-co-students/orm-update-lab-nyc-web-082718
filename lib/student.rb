require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  # CLASS METHODS

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    s = Student.new(name, grade)
    s.save
    s
  end

  def self.new_from_db(row)
    s = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name)[0]

    Student.new_from_db(row)
  end

  # INSTANCE METHODS

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)

      rows = DB[:conn].execute("SELECT last_insert_rowid() FROM students")
      @id = rows[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?,
          grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
