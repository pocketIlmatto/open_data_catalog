require_relative 'database'
class QueryHelper

  def self.append_options(sql, options)
    sql += options[:condition] ? "WHERE #{options[:condition]} " : ""
    sql += options[:limit] ? "LIMIT #{options[:limit]} " : ""
    sql += ";"
    puts sql
    sql
  end

  def self.get_square_miles(options = {limit: 5})
    table_name = Database::config["default"]["geometry_table_name"]
    sql = "SELECT rotulo, " +
      "round((ST_Area(geom::geography) / 2589988.110336)::numeric, 2) " +
        "AS square_miles " +
      "FROM #{table_name} "
    sql = QueryHelper::append_options(sql, options)
  end

end