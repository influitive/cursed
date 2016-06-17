# frozen_string_literal: true

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

ActiveRecord::Base.connection.instance_eval do
  create_table(:widgets, force: true) do |t|
    t.integer :cursor
    t.string :name
  end
end

class Widget < ActiveRecord::Base
end
