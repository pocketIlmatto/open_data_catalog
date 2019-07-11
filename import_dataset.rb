Dir[File.dirname(__FILE__) + '/services/*.rb'].each {|file| require file }
require 'roo-xls'

config_file_name = 'spanish_2011'

DataDownloader.fetch_data(config_file_name)

Database::find_or_initDB

config = YAML.load(
      File.open(File.join(File.dirname(__FILE__),
        "./config/#{config_file_name}.yaml")).read
    )
if config['drop_geometry_table']
  Database::drop_table(Database::config["default"]["geometry_table_name"])
end
if config['drop_statistical_table']
  Database::drop_table(Database::config["default"]["statistical_table_name"])
end

Dir[DataDownloader::shp_data_directory + '/*.shp'].each do |shp_file|
  ShapeFileImporter::call(shp_file)
end

# Assumes the data is in sheet 1
field_mappings_file = DataDownloader::field_mappings_filename
field_mappings = Roo::Excel.new(field_mappings_file).sheet(1).parse.to_h

Dir[DataDownloader::census_data_directory + '/*.csv'].each do |stat_file|
  StatisticalDataImporter::call(stat_file, field_mappings)
end

DataDownloader::clean_up_data