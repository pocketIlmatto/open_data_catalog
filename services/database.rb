require 'pg'
require 'yaml'

class Database

  def self.config
    YAML.load(
      File.open(File.join(File.dirname(__FILE__),
        '../config/database.yaml')).read
    )
  end

  def self.conn
    db_name = Database::config["default"]["database"]
    conn = PG.connect(dbname: db_name)
  end

  def self.drop_table(table_name)
    begin
      puts "DROP TABLE #{table_name}."
      Database::exec("DROP TABLE #{table_name}")
    rescue PG::UndefinedTable
      puts "#{table_name} doesn't exist. Skipping DROP TABLE command"
    end
  end

  def self.exec(sql)
    conn = Database::conn
    conn.exec(sql)
  end

  def self.find_or_initDB
    db_name = Database::config["default"]["database"]
    begin
      conn = PG.connect(dbname: 'postgres')
      conn.exec("CREATE DATABASE #{db_name}")
      puts "Database: #{db_name} created."
    rescue PG::DuplicateDatabase
      puts "Database: #{db_name} already exists."
    end

    begin
      Database::exec("CREATE EXTENSION postgis")
      puts "Enabling PostGIS extension on #{db_name}."
    rescue PG::DuplicateObject
      puts "PostGIS extension already enabled on #{db_name}."
    end
  end

  def self.table_exists?(table_name)
    sql = "SELECT EXISTS ( SELECT 1 FROM information_schema.tables WHERE " +
      "table_name = '#{table_name}');"
    result = Database::exec(sql)
    result[0]["exists"] == 't' ? true : false
  end
end