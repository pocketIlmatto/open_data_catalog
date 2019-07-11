Dir[File.dirname(__FILE__) + '/services/*.rb'].each {|file| require file }
require 'roo-xls'

# TODO: Download the files based on passed in config file or args

Database::find_or_initDB

# TODO: Only drop tables if config/arg indicates
Database::drop_table(Database::config["default"]["geometry_table_name"])
Database::drop_table(Database::config["default"]["statistical_table_name"])

Dir[File.dirname(__FILE__) + '/data/shp_files/*.shp'].each do |shp_file|
  ShapeFileImporter::call(shp_file)
end

field_mappings_file = File.dirname(__FILE__) + '/data/field_mappings.xls'
field_mappings = Roo::Excel.new('./data/field_mappings.xls').sheet(1).parse.to_h

Dir[File.dirname(__FILE__) + '/data/census_data/*.csv'].each do |stat_file|
  StatisticalDataImporter::call(stat_file, field_mappings)
end

# TODO: Clean up all downloaded files