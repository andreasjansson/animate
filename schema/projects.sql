CREATE TABLE projects (
        `name`          CHAR(8)         NOT NULL PRIMARY KEY,
        password        VARCHAR(50)     NOT NULL,
        audio_url       VARCHAR(200)    NOT NULL,
        analysis        TEXT            NOT NULL,
        data            TEXT,
        edit_key        VARCHAR(50),
        date_created    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) DEFAULT CHARSET=utf8;
