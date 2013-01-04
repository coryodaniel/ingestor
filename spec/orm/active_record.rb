# encoding: utf-8
require 'active_record'

ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new('log/test.log')
ActiveRecord::Base.establish_connection YAML.load(File.open(File.join(File.dirname(__FILE__), 'database.yml')).read)[ENV['db'] || 'sqlite3']

ActiveRecord::Migration.verbose = false

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :countries, :force => true do |t|
      t.column :name, :string
      t.column :colors, :string
      t.column :count, :integer
    end

    create_table :dummies, :force => true do |t|
      t.column :name, :string
      t.timestamps
    end    
  end

  def self.down
    drop_table :countries
    drop_table :dummies
  end
end

class Dummy < ActiveRecord::Base;end;
class Country < ActiveRecord::Base;end;