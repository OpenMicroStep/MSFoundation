-- message table creation
CREATE TABLE message(messageID TEXT PRIMARY KEY, messageGroup INTEGER, contentType TEXT, sender TEXT, recipient TEXT, creationDate INTEGER, receivingDate INTEGER, thread TEXT, validity INTEGER, route TEXT, priority INTEGER, status INTEGER, externalReference TEXT, content BLOB);
CREATE INDEX messageID_idx ON message (messageID) ;
CREATE INDEX recipient_idx ON message (recipient) ;
CREATE INDEX thread_idx ON message (thread) ;
CREATE INDEX status_idx ON message (status) ;
CREATE INDEX externalReference_idx ON message (externalReference) ;

-- parameters table creation
CREATE TABLE parameters(name TEXT PRIMARY KEY, value1 INTEGER, value2 TEXT, value3 INTEGER);
INSERT INTO parameters (name, value1, value2, value3) VALUES('dbVersion',1,'',0) ;

-- indexes table creation
CREATE TABLE indexes(name TEXT PRIMARY KEY, value INTEGER );
INSERT INTO indexes (name, value) VALUES('messageGroup',1) ;