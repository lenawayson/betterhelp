class ResultsController < ApplicationController
  def show
    @happy_results = most_popular_answers(happiness_answer_id: Answer::HAPPINESS_YES_ID)
    @unhappy_results = most_popular_answers(happiness_answer_id: Answer::HAPPINESS_NO_ID)
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def most_popular_answers(happiness_answer_id:)
    rows = connection.exec_query(
      <<~SQL.squish,
        SELECT
          question_id,
          question_title,
          answer_id,
          answer_text,
          selection_count
        FROM (
          SELECT DISTINCT ON (q.id)
            q.id AS question_id,
            q.title AS question_title,
            q.display_order AS question_order,
            a.id AS answer_id,
            a.display_text AS answer_text,
            COUNT(*) AS selection_count
          FROM response_answers ra
          JOIN questions q ON q.id = ra.question_id
          JOIN answers a ON a.id = ra.answer_id
          WHERE ra.survey_response_id IN (
            SELECT survey_response_id
            FROM response_answers
            WHERE answer_id = $1
          )
          GROUP BY q.id, q.title, q.display_order, a.id, a.display_text, a.display_order
          ORDER BY q.id, COUNT(*) DESC, a.display_order
        ) top_answers
        ORDER BY question_order
      SQL
      "results_controller.most_popular_answers",
      [
        ActiveRecord::Relation::QueryAttribute.new(
          "happiness_answer_id",
          happiness_answer_id,
          ActiveRecord::Type::BigInteger.new
        )
      ]
    )

    rows.map do |row|
      {
        question_id: row["question_id"],
        question_title: row["question_title"],
        answer_id: row["answer_id"],
        answer_text: row["answer_text"],
        selection_count: row["selection_count"]
      }
    end
  end
end
