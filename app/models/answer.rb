class Answer < ApplicationRecord
  belongs_to :question
  has_many :response_answers
end
