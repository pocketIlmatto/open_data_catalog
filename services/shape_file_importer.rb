require_relative 'database'

class ShapeFileImporter

  def self.call(file)
    # TODO sanitize file name?
    config = Database::config["default"]

    table_name = config["geometry_table_name"]
    host = config["host"]
    db_name = config["database"]
    geom_name = config["geometry_field_name"]
    username = config["username"]

    ogr2ogr = "ogr2ogr -lco GEOMETRY_NAME=#{geom_name} -addfields -f " +
      "'PostgreSQL' PG:'host=#{host} user=#{username} " +
      "dbname=#{db_name}' #{file} -nln #{table_name} -nlt MultiPolygon -lco " +
      "PRECISION=no"

    file_name = File.basename(file, ".*")
    puts "Importing data for #{file_name}."

    system(ogr2ogr)

    puts "Finished importing data for #{file_name}."
  end

end