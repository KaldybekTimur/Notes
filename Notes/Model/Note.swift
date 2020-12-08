//
//  Note.swift
//  Notes
//
//  Created by Timur on 12/4/20.
//

import Foundation
import SQLite3

struct Note {
    let id: Int
    var contents: String
}

class NoteManager{
    
    static let main = NoteManager()
    
    private init(){}
    
    var database: OpaquePointer! /// some point in memory where locate the base
    func connect(){
        // проверка для того, чтобы постоянно не подключался к базе
        if database != nil{
            return
        }
        do{
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("notes.sqlite3")
           
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK { /// &database - ссылка где будут храниться данные
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS notes (contents TEXT)", nil, nil, nil) == SQLITE_OK {
                    
                    // MARK: - Code here...
                    
                } else {
                    print("Could not create table")
                }
            } else {
                print("Couldn't connect")
            }
        }catch let error{
            print("Couldn't connect ", error)
        }
    }
    func create() -> Int{
        connect()
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO notes (contents) VALUES ('new note')", -1, &statement, nil) != SQLITE_OK{
            print("Could not create query")
            return -1
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not insert note")
            return -1
        }
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database)) 
    }
    
    func getAllNotes() -> [Note]{
     //0 - check connection
        connect()
    //1 - create statement
        var result: [Note] = []
        var statement: OpaquePointer!
    //2 - prepare this statement
        if sqlite3_prepare_v2(database, "SELECT rowid, contents FROM notes", -1, &statement, nil) != SQLITE_OK {
            print("Error creating select")
            return []
        }
    //3 - execute that statement in loop or once
        while sqlite3_step(statement) == SQLITE_ROW{
            result.append(Note(id: Int(sqlite3_column_int(statement, 0)), contents: String(cString: sqlite3_column_text(statement, 1))))
        }
    //4 - finalize it
        sqlite3_finalize(statement)
        return result
    }
    
    func save(_ note: Note){
        connect()
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "UPDATE notes SET contents = ? WHERE rowid = ? ", -1, &statement, nil) != SQLITE_OK {
            print("error creating update statement")
        }
        sqlite3_bind_text(statement, 1, NSString(string: note.contents).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(note.id))
      //execute
        if sqlite3_step(statement) != SQLITE_DONE{
            print("error running update ")
        }
        sqlite3_finalize(statement)
    }
}
