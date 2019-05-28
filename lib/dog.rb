require 'pry'

class Dog

  @@all = []

  attr_accessor :id, :name, :breed

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    if self.id == nil
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    self.create_table
     dog = Dog.new(hash)
     dog.save
     if dog.id == nil
       dog.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.id = ?
    SQL

    hash = {
      :id => id
    }

    DB[:conn].execute(sql, id).map do |row|
      hash[:name] = row[1]
      hash[:breed] = row[2]
    end
    found_dog = Dog.all.find {|dog| dog.id == id}
    found_dog
  end

  def self.find_or_create_by(name:, breed:)

    dog = self.find_by_name(name)

    if dog.breed != breed
      hash = {
          :name => name,
          :breed => breed
        }
      new_dog = self.create(hash)
      new_dog
    else
      dog
    end
  end

  def self.new_from_db(row)
      hash = {
        id: row[0],
        name: row[1],
        breed: row[2]
      }
      dog = self.new(hash)
      dog
  end

def self.find_by_name(name)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    if self.id == nil
      self.save
    else
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end
  end

end
