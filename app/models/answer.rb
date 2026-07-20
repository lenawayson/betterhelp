class Answer < ApplicationRecord
  # Matches seed data in db/seeds/survey_data.sql ("Are you happy?" → Yes / No).
  HAPPINESS_YES_ID = 4
  HAPPINESS_NO_ID = 5

  belongs_to :question
  has_many :response_answers
end
