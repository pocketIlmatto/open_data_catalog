require_relative 'database'
require 'csv'

class StatisticalDataImporter

  def self.create_or_alter_table(file, field_mappings)
    column_names = CSV.read(file)[0]

    identifier_fields = column_names.map do |column|
      field_mappings[column] ? nil : column
    end.compact!

    unless Database::table_exists?(StatisticalDataImporter::table_name)
      # TODO - determine data type on the fly
      puts "Creating #{StatisticalDataImporter::table_name}"
      sql = "CREATE TABLE #{StatisticalDataImporter::table_name} ( " +
        "id SERIAL PRIMARY KEY, "
      identifier_fields.each do |col|
        sql += "#{col} VARCHAR(100), "
      end
      sql += "stat_type VARCHAR(100) NOT NULL, " +
        "value VARCHAR(100));"

      Database.exec(sql)
    else
      sql = "SELECT * FROM information_schema.columns " +
      "WHERE table_name = '#{StatisticalDataImporter::table_name}';"

      existing_column_names = Database::exec(sql).map { |r| r["column_name"]}
      columns_to_add = identifier_fields - existing_column_names
      if columns_to_add.length > 0
        puts "Adding #{columns_to_add} columns to " +
          "#{StatisticalDataImporter::table_name}"
        sql = "ALTER TABLE #{StatisticalDataImporter::table_name} "
        columns_to_add.each do |col|
          sql += "ADD COLUMN #{col} VARCHAR(100),"
        end
        sql = sql.delete_suffix(',') + ';'
        Database.exec(sql)
      end
    end
  end

  def self.import_data(file, field_mappings)
    # TODO Are there better ways of parsing large CSV files?
    csv = CSV.parse(File.open(file), headers: true)

    stat_fields = csv.headers.select{ |c| field_mappings[c] }
    identifier_fields = csv.headers - stat_fields
    column_sql = identifier_fields.join(', ') + ", stat_type, value"

    puts "Building import statements for file #{file}."

    row_count = 0
    csv.each do |row|
      sql = "INSERT INTO " +
          "#{StatisticalDataImporter::table_name}(#{column_sql}) " +
          "VALUES "
      stat_fields.each do |stat|
        row_count += 1
        sql += '('
        identifier_fields.each do |i|
          sql += "'#{row[i]}', "
        end
        sql += "'#{stat}', "
        sql += "'#{row[stat]}'"
        sql += '),'
      end
      sql = sql.delete_suffix(',') + ';'
      Database.exec(sql)
    end
    puts "Imported #{row_count} rows into " +
      "#{StatisticalDataImporter::table_name}"
  end

  def self.table_name
    Database.config["default"]["statistical_table_name"]
  end

  def self.call(file, field_mappings)
    StatisticalDataImporter::create_or_alter_table(file, field_mappings)
    StatisticalDataImporter::import_data(file, field_mappings)
  end
end