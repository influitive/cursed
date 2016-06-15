# frozen_string_literal: true

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
