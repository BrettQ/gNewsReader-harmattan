/*
    Copyright 2011 - Yogeshwar Padhyegurjar

    This file is part of gNewsReader.

    gNewsReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gNewsReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with gNewsReader. If not, see <http://www.gnu.org/licenses/>.
*/

//storage.js
// First, let's create a short helper function to get the database connection
function getDatabase() {
     return openDatabaseSync("gNewsReader", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
            //tx.executeSql('CREATE TEMP TABLE IF NOT EXISTS tmp_sub(id TEXT UNIQUE, title TEXT, parentid TEXT, parenttitle TEXT, istag BOOLEAN, issub BOOLEAN, count INTEGER )');
          });
}

// This function is used to write a setting into the database
function setSetting(setting, value) {
   // setting: string representing the setting name (eg: “username”)
   // value: string representing the value of the setting (eg: “myUsername”)
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
              //console.log(rs.rowsAffected)
              if (rs.rowsAffected > 0) {
                res = "OK";
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to retrieve a setting from the database
function getSetting(setting) {
   var db = getDatabase();
   var res="";
   db.readTransaction(function(tx) {
     var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
     if (rs.rows.length > 0) {
          res = rs.rows.item(0).value;
     } else {
         res = "Unknown";
     }
  })
  // The function returns “Unknown” if the setting was not found in the database
  // For more advanced projects, this should probably be handled through error codes
  return res
}

function getSettingVal(setting, defaultVal) {
    var retVal = getSetting(setting)
    return (retVal == "Unknown" ? defaultVal : retVal)
}

//// This function is used to write a sub/tag into the temp database
//function setTagSub(id, title, parentid, parenttitle, isTag, isSub) {
//   // setting: string representing the setting name (eg: “username”)
//   // value: string representing the value of the setting (eg: “myUsername”)
//   var db = getDatabase();
//   var res = "";
//   db.transaction(function(tx) {
//        var rs = tx.executeSql('INSERT OR REPLACE INTO tmp_sub VALUES (?,?,?,?,?,?,0);', [id, title, parentid, parenttitle, (isTag?1:0), (isSub?1:0)]);
//              //console.log(rs.rowsAffected)
//              if (rs.rowsAffected > 0) {
//                res = "OK";
//              } else {
//                res = "Error";
//              }
//        }
//  );
//  // The function returns “OK” if it was successful, or “Error” if it wasn't
//  return res;
//}

//// This function is used to write a sub/tag id and count into the temp database
//function setTagSubCount(id, count) {
//   // setting: string representing the setting name (eg: “username”)
//   // value: string representing the value of the setting (eg: “myUsername”)
//   var db = getDatabase();
//   var res = "";
//   db.transaction(function(tx) {
//        var rs = tx.executeSql('INSERT OR REPLACE INTO tmp_sub VALUES (?,null,null,null,0,0,?);', [id, count]);
//              //console.log(rs.rowsAffected)
//              if (rs.rowsAffected > 0) {
//                res = "OK";
//              } else {
//                res = "Error";
//              }
//        }
//  );
//  // The function returns “OK” if it was successful, or “Error” if it wasn't
//  return res;
//}

//// This function is used to clear a sub/tag temp database table
//function clearTagSub() {
//   // setting: string representing the setting name (eg: “username”)
//   // value: string representing the value of the setting (eg: “myUsername”)
//   var db = getDatabase();
//   var res = "";
//   db.transaction(function(tx) {
//        var rs = tx.executeSql('DELETE FROM tmp_sub;');
//              //console.log(rs.rowsAffected)
////              if (rs.rowsAffected > 0) {
//                res = "OK";
////              } else {
////                res = "Error";
////              }
//        }
//  );
//  // The function returns “OK” if it was successful, or “Error” if it wasn't
//  return res;
//}

//function setTagSubCount(id, count) {
//    var db = getDatabase();
//    var res = "";
//    db.transaction(function(tx) {
//                var rs = tx.executeSql('UPDATE tmp_sub SET count=? WHERE id=?;', [count, id]);
//               //console.log(rs.rowsAffected)
//               if (rs.rowsAffected > 0) {
//                 res = "OK";
//               } else {
//                 res = "Error";
//               }
//         }
//   );
//   // The function returns “OK” if it was successful, or “Error” if it wasn't
//   return res;
//}

//function updateTagSubCount(id, count) {
//    //console.log("Calling update count on:"+id+" count:"+count)
//    var db = getDatabase();
//    var res = "";
//    db.transaction(function(tx) {
//                var rs = tx.executeSql('UPDATE tmp_sub SET count = (count - ?) WHERE id=?;', [count, id]);
//               //console.log(rs.rowsAffected)
//               if (rs.rowsAffected > 0) {
//                 res = "OK";
//               } else {
//                 res = "Error";
//               }
//               //console.log("result:"+res)
//         }
//   );
//   // The function returns “OK” if it was successful, or “Error” if it wasn't
//   return res;
//}

//function getTagSub(listmodel, unreadyOnly) {
//    var db = getDatabase();
//    var res = "";
//    db.transaction(function(tx) {
//                       var rs = tx.executeSql(unreadyOnly?'SELECT * FROM tmp_sub WHERE count>0 ORDER By parenttitle;':'SELECT * FROM tmp_sub ORDER By parenttitle');
//                       var parenttitle = null
//                       for(var i = 0; i < rs.rows.length; i++) {
//                           if(parenttitle+"-" == rs.rows.item(i).parenttitle) subListModel.setProperty(i - 1, "cat", "folder")
//                           //console.log(rs.rows.item(i).parenttitle+ ", " + rs.rows.item(i).issub + ", "+rs.rows.item(i).isfolder);
//                           subListModel.append({"title": rs.rows.item(i).title, "itemId":rs.rows.item(i).id, "count": rs.rows.item(i).count, "cat":(rs.rows.item(i).issub == "1" ?"sub":"tag"), "sub":rs.rows.item(i).issub == "1", "catid": rs.rows.item(i).parentid});
//                           //console.log(rs.rows.item(i).parenttitle+ ", " + rs.rows.item(i).issub + ", "+rs.rows.item(i).istag+", "+subListModel.get(i).cat);
//                           parenttitle = rs.rows.item(i).parenttitle
//                       }
//                   }
//                   );
//    return res;
//}
