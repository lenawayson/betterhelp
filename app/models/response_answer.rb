class ResponseAnswer < ApplicationRecord
  belongs_to :survey_response
  belongs_to :question
  belongs_to :answer
end
