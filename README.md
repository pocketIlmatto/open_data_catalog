# open_data_catalog
Ruby version of https://gist.github.com/javitonino/7f6f1183163d09b4c1817470e906ac4a

# Prerequisites
* Postgresql
* PostGIS
* Ruby 2.5.1
* bundler
* ogr2ogr

# Assumptions
* Census data is in zip file format. If not, change the code in the DataDownloader.
* Shp data is in zip file format. If not, change the code in the DataDownloader.
* Desired census data is contained in a single directory in the downloaded file. If not, change code in the DataDownloader
* Desired shp data is contained in a single directory in the downloaded file. If not, change code in the DataDownloader
* Assumes the field mappings file is xls format and the data is on sheet 1. If not, change the code in import_dataset.rb

# Usage
* Create a data-download config file. See **config/spanish_2011.yaml** for details.
* Create a database.yaml file. See **config/database_template.yaml** for details.
* Point **import_dataset.rb** at the data-download config file: 
  ```ruby
  config_file_name = 'spanish_2011'
  ```
* Install and run 
  ```sh
  bundle install
  ruby import_dataset.rb
  ```

