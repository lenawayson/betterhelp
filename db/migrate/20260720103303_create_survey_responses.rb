class CreateSurveyResponses < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TABLE survey_responses (
        id bigserial PRIMARY KEY,
        created_at timestamp(6) without time zone NOT NULL,
        updated_at timestamp(6) without time zone NOT NULL
      );
    SQL
  end

  def down
    execute <<~SQL
      DROP TABLE IF EXISTS survey_responses;
    SQL
  end
end
