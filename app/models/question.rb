class Question < ApplicationRecord
  has_many :answers
  has_many :response_answers
end
