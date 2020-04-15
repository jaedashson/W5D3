require 'sqlite3'
require_relative "questions_database"
require_relative "users.rb"
require_relative "questions.rb"

class QuestionFollow
    attr_accessor :id, :user_id, :question_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def self.find_by_id(other_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, other_id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
        QuestionFollow.new(data.first)
    end

    def self.followers_for_question_id(other_question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, other_question_id)
            SELECT
                *
            FROM
                users
            JOIN
                question_follows ON users.id = question_follows.user_id
            WHERE
                question_id = ?
        SQL
        data.map { |datum| User.new(datum) }
    end

    def self.followed_questions_for_user_id(other_user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, other_user_id)
            SELECT
                *
            FROM
                questions
            JOIN
                question_follows ON questions.id = question_follows.question_id
            WHERE
                question_follows.user_id = ?
        SQL
        data.map { |datum| Question.new(datum) }
        
    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end
    
    def create
        raise "#{self} already in database" if self.id
        QuestionsDatabase.instance.execute(<<-SQL, self.user_id, self.question_id)
            INSERT INTO
                question_follows (user_id, question_id)
            VALUES
                (?, ?)        
        SQL
        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless self.id
        QuestionsDatabase.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
            UPDATE
                question_follows
            SET
                user_id = ?, question_id = ?
            WHERE
                id = ?
        SQL
    end
end