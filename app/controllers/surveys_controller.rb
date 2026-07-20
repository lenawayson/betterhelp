class SurveysController < ApplicationController
  def show
    rows = connection.exec_query(<<~SQL.squish)
      SELECT
        q.id AS question_id,
        q.title AS question_title,
        q.question_type,
        q.display_order AS question_order,
        a.id AS answer_id,
        a.display_text AS answer_text,
        a.display_order AS answer_order
      FROM questions q
      INNER JOIN answers a ON a.question_id = q.id
      ORDER BY question_order ASC, answer_order ASC
    SQL

    @questions = group_questions(rows)
  end

  def create
    selections = normalize_selections(answers_params)
    unless selections.empty?
      connection.transaction do
        survey_response_id = insert_survey_response

        selections.each do |selection|
          insert_response_answer(
            survey_response_id: survey_response_id,
            question_id: selection[:question_id],
            answer_id: selection[:answer_id]
          )
        end
      end
    end

    redirect_to results_path
  end

  private

  def connection
    @connection ||= ActiveRecord::Base.connection
  end

  # radio:    answers[question_id] = answer_id
  # checkbox: answers[question_id] = [answer_id, ...]
  def answers_params
    params.fetch(:answers, ActionController::Parameters.new).permit!.to_h
  end

  def normalize_selections(answers_by_question)
    answers_by_question.flat_map do |question_id, value|
      Array(value).filter_map do |answer_id|
        next if answer_id.blank?

        {
          question_id: question_id.to_i,
          answer_id: answer_id.to_i
        }
      end
    end
  end

  def group_questions(rows)
    questions_by_id = {}

    rows.each do |row|
      question = questions_by_id[row["question_id"]] ||= {
        id: row["question_id"],
        title: row["question_title"],
        question_type: row["question_type"],
        display_order: row["question_order"],
        answers: []
      }

      question[:answers] << {
        id: row["answer_id"],
        display_text: row["answer_text"],
        display_order: row["answer_order"]
      }
    end

    questions_by_id.values
  end

  def insert_survey_response
    result = connection.exec_query(<<~SQL.squish)
      INSERT INTO survey_responses (created_at, updated_at)
      VALUES (NOW(), NOW())
      RETURNING id
    SQL

    result.first["id"]
  end

  def insert_response_answer(survey_response_id:, question_id:, answer_id:)
    connection.exec_query(
      <<~SQL.squish,
        INSERT INTO response_answers (
          survey_response_id,
          question_id,
          answer_id,
          created_at,
          updated_at
        )
        VALUES ($1, $2, $3, NOW(), NOW())
      SQL
      "surveys_controller.insert_response_answer",
      [
        ActiveRecord::Relation::QueryAttribute.new("survey_response_id", survey_response_id, ActiveRecord::Type::BigInteger.new),
        ActiveRecord::Relation::QueryAttribute.new("question_id", question_id, ActiveRecord::Type::BigInteger.new),
        ActiveRecord::Relation::QueryAttribute.new("answer_id", answer_id, ActiveRecord::Type::BigInteger.new)
      ]
    )
  end
end
