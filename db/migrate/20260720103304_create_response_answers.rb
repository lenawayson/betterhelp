class CreateResponseAnswers < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TABLE response_answers (
        id bigserial PRIMARY KEY,
        survey_response_id bigint NOT NULL REFERENCES survey_responses(id),
        question_id bigint NOT NULL REFERENCES questions(id),
        answer_id bigint NOT NULL REFERENCES answers(id),
        created_at timestamp(6) without time zone NOT NULL,
        updated_at timestamp(6) without time zone NOT NULL
      );

      CREATE INDEX index_response_answers_on_survey_response_id
        ON response_answers (survey_response_id);

      CREATE INDEX index_response_answers_on_answer_id
        ON response_answers (answer_id);
    SQL
  end

  def down
    execute <<~SQL
      DROP TABLE IF EXISTS response_answers;
    SQL
  end
end
