-- Initial survey questions and answers.
-- Safe to re-run: clears existing survey data first.

TRUNCATE TABLE response_answers, survey_responses, answers, questions
  RESTART IDENTITY CASCADE;

INSERT INTO questions (title, question_type, display_order, created_at, updated_at)
VALUES
  ('How old are you?', 'radio', 1, NOW(), NOW()),
  ('Are you happy?', 'radio', 2, NOW(), NOW()),
  ('What countries have you visited?', 'checkbox', 3, NOW(), NOW()),
  ('What is your favorite sport?', 'radio', 4, NOW(), NOW()),
  ('What programming languages do you know?', 'checkbox', 5, NOW(), NOW());

INSERT INTO answers (question_id, display_text, display_order, created_at, updated_at)
VALUES
  -- How old are you?
  (1, 'Less than 18', 1, NOW(), NOW()),
  (1, '18-99', 2, NOW(), NOW()),
  (1, 'More than 99', 3, NOW(), NOW()),

  -- Are you happy?
  (2, 'Yes', 1, NOW(), NOW()),
  (2, 'No', 2, NOW(), NOW()),

  -- What countries have you visited?
  (3, 'Spain', 1, NOW(), NOW()),
  (3, 'France', 2, NOW(), NOW()),
  (3, 'Italy', 3, NOW(), NOW()),
  (3, 'England', 4, NOW(), NOW()),
  (3, 'Portugal', 5, NOW(), NOW()),

  -- What is your favorite sport?
  (4, 'Football', 1, NOW(), NOW()),
  (4, 'Basketball', 2, NOW(), NOW()),
  (4, 'Soccer', 3, NOW(), NOW()),
  (4, 'Volleyball', 4, NOW(), NOW()),

  -- What programming languages do you know?
  (5, 'PHP', 1, NOW(), NOW()),
  (5, 'Ruby', 2, NOW(), NOW()),
  (5, 'JavaScript', 3, NOW(), NOW()),
  (5, 'Python', 4, NOW(), NOW());
