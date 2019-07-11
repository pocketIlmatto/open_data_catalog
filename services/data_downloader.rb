require 'down'
require 'fileutils'
require 'zip'

class DataDownloader

  def self.census_data_directory
    DataDownloader.data_directory + "/census_data"
  end

  def self.clean_up_data
    puts "Cleaning up data directory: #{DataDownloader::data_directory}"
    FileUtils.rm_rf(DataDownloader::data_directory)
  end

  def self.config(config_file_name)
    YAML.load(
      File.open(File.join(File.dirname(__FILE__),
        "../config/#{config_file_name}.yaml")).read
    )
  end

  def self.data_directory
    File.join(File.dirname(__FILE__), '../tmp_data')
  end

  def self.download(url)
    Down::NetHttp.download(url, open_timeout: 300)
  end

  def self.download_census_data(config)
    puts "Downloading census data into #{DataDownloader::census_data_directory}"
    begin
      Dir.mkdir(DataDownloader::census_data_directory, 0700)
    rescue Errno::EEXIST
    end

    tmp_file = DataDownloader::download(config["census_data"]["url"])
    # Assumes the file being downloaded here is a zip file
    tmp_file_path = DataDownloader::census_data_directory + '.zip'

    FileUtils.mv(tmp_file.path, tmp_file_path)

    if File.extname(tmp_file_path) == ".zip"
      Zip::File.open(tmp_file_path) do |zip_file|
        zip_file.glob("#{config["census_data"]["keep_path"]}").each do |entry|
          File.write(DataDownloader::census_data_directory + "/#{entry.name}",
            entry.get_input_stream.read)
        end
      end
    end
    begin
      File.open(tmp_file_path, 'r') do |f|
        File.delete(f)
      end
    rescue Errno::ENOENT
    end
  end

  def self.download_field_mappings(config)
    puts "Downloading field mappings file"
    tmp_file = DataDownloader::download(config["field_mappings"]["url"])

    FileUtils.mv(tmp_file.path, DataDownloader::field_mappings_filename)
  end

  def self.download_shp_data(config)
    puts "Downloading shp data files into #{DataDownloader::shp_data_directory}"
    begin
      Dir.mkdir(DataDownloader::shp_data_directory, 0700)
    rescue Errno::EEXIST
    end

    tmp_file = DataDownloader::download(config["shp_data"]["url"])
    # Assumes the file being downloaded is a zip file
    tmp_file_path = DataDownloader::shp_data_directory + '.zip'

    FileUtils.mv(tmp_file.path, tmp_file_path)

    if File.extname(tmp_file_path) == ".zip"
      Zip::File.open(tmp_file_path) do |zip_file|
        zip_file.glob("#{config["shp_data"]["keep_path"]}").each do |entry|
          File.write(DataDownloader::shp_data_directory +
            "/#{entry.name.gsub('/', '_')}", entry.get_input_stream.read)
        end
      end
    end
    begin
      File.open(tmp_file_path, 'r') do |f|
        File.delete(f)
      end
    rescue Errno::ENOENT
    end
  end

  def self.fetch_data(config_file_name)
    config = DataDownloader::config(config_file_name)

    begin
      Dir.mkdir(DataDownloader.data_directory, 0700)
    rescue Errno::EEXIST
    end

    DataDownloader::download_field_mappings(config)
    DataDownloader::download_census_data(config)
    DataDownloader::download_shp_data(config)
  end

  # Assumes xls file type
  def self.field_mappings_filename
    DataDownloader::data_directory + "/field_mappings.xls"
  end

  def self.shp_data_directory
    DataDownloader.data_directory + "/shp_file_data"
  end

end