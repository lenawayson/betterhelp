# BetterHelp Survey Challenge

A small Rails survey app built for a technical interview exercise. Questions and answers are **not hardcoded** — they live in PostgreSQL and are loaded, submitted, and aggregated with **raw SQL**. Rails is used for routing, controllers, views, and migrations, not for Active Record query APIs.

## Quick start

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Then open:

| URL | Purpose |
|-----|---------|
| http://localhost:3000/ | Survey form |
| http://localhost:3000/survey | Same form (`GET`) / submit (`POST`) |
| http://localhost:3000/results | Happy vs unhappy popularity results |

Requirements: Ruby (see `.ruby-version`), PostgreSQL, Bundler.

## What the challenge asks for

1. Dynamically generate the survey from the database
2. Support `radio` (exactly one) and `checkbox` (zero or more) question types
3. Store anonymous submissions
4. Show the most popular answer per question among **happy** and **unhappy** users
5. Do **not** use Active Record query methods such as `Question.all`, `.where`, `.find`, `.create`, `.joins`, `.group`, etc.
6. Prefer parameterized raw SQL, transactions, and SQL-side aggregation

## How we avoided Active Record queries

Models still exist (`Question`, `Answer`, `SurveyResponse`, `ResponseAnswer`) mainly for:

- documenting associations (`has_many` / `belongs_to`)
- holding a few constants (e.g. happiness answer IDs)

They are **not** used to load or write survey data.

All reads and writes go through `ActiveRecord::Base.connection`:

```ruby
connection.exec_query(<<~SQL.squish)
  SELECT ...
  FROM questions q
  INNER JOIN answers a ON a.question_id = q.id
  ...
SQL
```

That uses Active Record only as a **connection / transaction / bind** helper — not as an ORM query layer. Inserts use bound parameters (`$1`, `$2`, …) via `QueryAttribute` to protect against SQL injection. User input is never string-interpolated into SQL.

Migrations and seeds also use raw SQL (`execute <<~SQL`), and `config.active_record.schema_format = :sql` keeps `db/structure.sql` as the schema source of truth.

## Architecture

```
Browser
  │
  ├─ GET  /survey   → SurveysController#show
  │                     raw SELECT questions ⨝ answers
  │                     group rows in Ruby for the view
  │
  ├─ POST /survey   → SurveysController#create
  │                     normalize params → transaction
  │                     INSERT survey_responses
  │                     INSERT response_answers (parameterized)
  │
  └─ GET  /results  → ResultsController#show
                        raw aggregation with JOIN / GROUP BY / COUNT
                        DISTINCT ON to pick the winning answer per question
```

### Schema 

| Table | Role |
|-------|------|
| `questions` | Prompt text, `question_type` (`radio` \| `checkbox`), `display_order` |
| `answers` | Options for each question (`question_id`, `display_text`, `display_order`) |
| `survey_responses` | One anonymous submission |
| `response_answers` | Selected answers for a submission (`survey_response_id`, `question_id`, `answer_id`) |

No `users` table — submissions are anonymous.

Display order is enforced in the DB with uniqueness constraints.

Changing the survey means changing rows (or re-seeding), not changing Ruby conditionals on question text.

### Controllers hold the SQL on purpose

For this challenge we kept SQL **in the controllers** so the solution stays easy to navigate in an interview: one place to read “how does show/create/results talk to Postgres?”

Private methods still separate concerns inside the controller:

- load / group questions & answers
- normalize form parameters
- insert response + answers inside a transaction in case of DB failure
- run the results aggregation to display results

### Submitting answers

Params shape:

```ruby
# radio
answers[question_id] = answer_id

# checkbox
answers[question_id] = [answer_id, ...]
```

`create` flattens that into `{ question_id, answer_id }` pairs, then in a **transaction**:

1. `INSERT INTO survey_responses … RETURNING id`
2. one parameterized `INSERT INTO response_answers` per selection

If the insert set is empty, nothing is written (checkboxes can all be blank; radios are required in the UI via HTML `required`).

### Results: happy vs unhappy in SQL

Happy / unhappy are defined by which happiness answer was chosen (seed IDs, not title string matching in the hot path):

```ruby
Answer::HAPPINESS_YES_ID  # "Yes"
Answer::HAPPINESS_NO_ID   # "No"
```

The aggregation:

1. Find `survey_response_id`s that selected that happiness `answer_id`
2. Among those responses, `COUNT(*)` each answer per question
3. Use PostgreSQL `DISTINCT ON (q.id) … ORDER BY q.id, COUNT(*) DESC, …` to keep the top answer per question
4. Outer `ORDER BY` restores survey display order

## Seeds

```bash
bin/rails db:seed
```

Runs `db/seeds/survey_data.sql` (truncate + insert). Safe to re-run; it resets questions/answers and clears responses.

## Tradeoffs

### Controllers vs query objects

Putting SQL in controllers is fine for a small app and a timed exercise. In production you would often extract query objects or a repository so controllers stay HTTP-focused and SQL can be unit-tested in isolation.

### Parameterization & injection

User-controlled values go through binds (`$1`, …) or are coerced with `.to_i` before use. Static SQL strings never interpolate params. That is the main SQL-injection defense.

### Happy/unhappy constants

Using answer IDs is simpler and faster than joining on question title + answer text every time. The tradeoff: seeds (or migrations) must keep those IDs stable, or the constants must be updated. Alternatively you could query on answer display text ("Yes" or "No") but it requires an additional table join.

### Validation

Radios use HTML `required` for UX. Checkboxes intentionally allow zero selections. Stronger server-side validation (reject missing radios even if the client is bypassed) is a natural follow-up; the current create path focuses on persistence and the challenge’s SQL requirements.

## Project map

```
app/controllers/surveys_controller.rb   # load form + submit (raw SQL)
app/controllers/results_controller.rb   # aggregation (raw SQL)
app/views/surveys/show.html.erb         # dynamic radio/checkbox form
app/views/results/show.html.erb         # happy / unhappy results
db/migrate/                             # CREATE TABLE + constraints via execute
db/seeds/survey_data.sql                # initial questions & answers
db/structure.sql                        # SQL schema dump
```
