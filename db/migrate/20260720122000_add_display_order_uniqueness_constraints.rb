class AddDisplayOrderUniquenessConstraints < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      ALTER TABLE questions
        ADD CONSTRAINT questions_display_order_unique UNIQUE (display_order);

      ALTER TABLE answers
        ADD CONSTRAINT answers_question_id_display_order_unique
        UNIQUE (question_id, display_order);
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE answers
        DROP CONSTRAINT IF EXISTS answers_question_id_display_order_unique;

      ALTER TABLE questions
        DROP CONSTRAINT IF EXISTS questions_display_order_unique;
    SQL
  end
end
