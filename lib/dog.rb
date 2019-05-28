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
    self
  end

  def self.create(hash)
    self.create_table
     dog = Dog.new(hash)
     dog.save
     if !dog.id == nil
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
binding.pry
    dog = self.find_by_name(name)

    if dog == nil
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
  name =  row[1]
  breed = row[2]
  dog = self.new(name, breed)  # self.new is the same as running student.new
  dog.id = row[0]
  dog  # return the newly created instance
end

def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

end
