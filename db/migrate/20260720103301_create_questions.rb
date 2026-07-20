class CreateQuestions < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TABLE questions (
        id bigserial PRIMARY KEY,
        title text NOT NULL,
        question_type character varying NOT NULL,
        display_order integer NOT NULL,
        created_at timestamp(6) without time zone NOT NULL,
        updated_at timestamp(6) without time zone NOT NULL,
        CONSTRAINT questions_question_type_check
          CHECK (question_type IN ('radio', 'checkbox'))
      );
    SQL
  end

  def down
    execute <<~SQL
      DROP TABLE IF EXISTS questions;
    SQL
  end
end
