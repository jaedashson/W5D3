PRAGMA foreign_keys = ON;

--Consider when/where/if CASCADE is needed
--Optionally you can DROP TABLEs before CREATE TABLEs in reverse order of table creation
--
--First DROP TABLEs in order of most to least dependencies
--Then CREATE TABLEs in order of least to most dependencies
--Seed in the same order that the tables are created 

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    subject_question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    user_id INTEGER NOT NULL,
    body TEXT,

    FOREIGN KEY (subject_question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT,
    body TEXT,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

INSERT INTO
    users (fname, lname)
VALUES
    ('Jesse', 'Lin'),
    ('Jae-Son', 'Song'),
    ('Young', 'Thug'),
    ('Aubrey', 'Graham');

INSERT INTO
    questions (title, body, user_id)
VALUES
    ('What is SQL?', 'Idk what SQL is',
    (SELECT id FROM users WHERE fname='Young' AND lname='Thug')),
    
    ('Where do babies come from?', 'Question body',
    (SELECT id FROM users WHERE fname='Aubrey' AND lname='Graham'));

INSERT INTO
    question_follows (user_id, question_id)
VALUES  
    ((SELECT id FROM users WHERE fname='Jesse' AND lname= 'Lin'),
    (SELECT id from questions WHERE title='What is SQL?')),

    ((SELECT id FROM users WHERE fname='Jae-Son' AND lname= 'Song'),
    (SELECT id from questions WHERE title='Where do babies come from?'));

    
INSERT INTO 
    replies (subject_question_id, parent_reply_id, user_id, body)
VALUES
    ((SELECT id FROM questions WHERE title='What is SQL?'),
    NULL,
    (SELECT id FROM users WHERE fname='Jae-Son' AND lname= 'Song'),
    'Structured Query Language');

INSERT INTO --Needs seperate INSERTS, replies rely on previous instances of replies for parent_reply_id.
    replies (subject_question_id, parent_reply_id, user_id, body)
VALUES
    ((SELECT id FROM questions WHERE title='What is SQL?'), 
    (SELECT id from replies WHERE body='Structured Query Language'), 
    (SELECT id FROM users WHERE fname='Jesse' AND lname= 'Lin'), 
    'What is that');

INSERT INTO
    question_likes (user_id, question_id)
VALUES  
    ((SELECT id FROM users WHERE fname='Jesse' AND lname= 'Lin'),
    (SELECT id from questions WHERE title='Where do babies come from?')),

    ((SELECT id FROM users WHERE fname='Jae-Son' AND lname= 'Song'),
    (SELECT id from questions WHERE title='What is SQL?'));