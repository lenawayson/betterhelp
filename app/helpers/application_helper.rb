module ApplicationHelper
  def selected_answer_ids(question_id)
    value = params.dig(:answers, question_id.to_s)
    Array(value).map(&:to_i)
  end
end
