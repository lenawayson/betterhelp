class CreateAnswers < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TABLE answers (
        id bigserial PRIMARY KEY,
        question_id bigint NOT NULL REFERENCES questions(id),
        display_text text NOT NULL,
        display_order integer NOT NULL,
        created_at timestamp(6) without time zone NOT NULL,
        updated_at timestamp(6) without time zone NOT NULL
      );

      CREATE INDEX index_answers_on_question_id ON answers (question_id);
    SQL
  end

  def down
    execute <<~SQL
      DROP TABLE IF EXISTS answers;
    SQL
  end
end
