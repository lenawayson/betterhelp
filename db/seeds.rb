# Loads survey questions and answers from SQL.
# No Active Record create/update calls — raw SQL only.
#
#   bin/rails db:seed

connection = ActiveRecord::Base.connection
seed_sql = Rails.root.join("db/seeds/survey_data.sql").read
connection.execute(seed_sql)
