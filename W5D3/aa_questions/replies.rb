require 'sqlite3'
require_relative "questions_database"
require_relative "users.rb"
require_relative "questions.rb"

class Reply
    attr_accessor :id, :subject_question_id, :parent_reply_id, :user_id, :body

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(other_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, other_id)
            SELECT
              *
            FROM
              replies
            WHERE
              id = ?
        SQL
        Reply.new(data.first)
    end

    def self.find_by_user_id(other_user_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, other_user_id)
        SELECT
          *
        FROM
          replies
        WHERE
          user_id = ?
      SQL
      data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_question_id(other_question_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, other_question_id)
        SELECT
          *
        FROM
          replies
        WHERE
          subject_question_id = ?
      SQL
      data.map { |datum| Reply.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @subject_question_id = options['subject_question_id']
        @parent_reply_id = options['parent_reply_id']
        @user_id = options['user_id']
        @body = options['body']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDatabase.instance.execute(<<-SQL, self.subject_question_id, self.parent_reply_id, self.user_id, self.body)
            INSERT INTO
              replies (subject_question_id, parent_reply_id, user_id, body)
            VALUES
              (?, ?, ?, ?)
        SQL
        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless self.id
        QuestionsDatabase.instance.execute(<<-SQL, self.subject_question_id, self.parent_reply_id, self.user_id, self.body, self.id)
            UPDATE
              replies
            SET
              subject_question_id = ?, parent_reply_id = ?, user_id = ?, body = ?
            WHERE
              id = ?
        SQL
    end

    def author
        data = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
            SELECT
              *
            FROM
              users
            WHERE
              id = ?
        SQL
        User.new(data.first)
    end

    def question
        data = QuestionsDatabase.instance.execute(<<-SQL, self.subject_question_id)
            SELECT
              *
            FROM
              questions
            WHERE
              id = ?
        SQL
        Question.new(data.first)
    end

    def parent_reply
        data = QuestionsDatabase.instance.execute(<<-SQL, self.parent_reply_id)
            SELECT
              *
            FROM
              replies
            WHERE
              id = ?
        SQL
        Reply.new(data.first)
    end
end