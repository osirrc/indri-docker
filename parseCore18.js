//@ts-check

"use strict";
let fileToProcess = process.argv[2];
let outFile = process.argv[3];

const readline = require('readline');  
const fs = require('fs');  

const readInterface = readline.createInterface({  
    input: fs.createReadStream(fileToProcess)
});

let lineCounter = 0;
readInterface.on('line', function(line) {  
    lineCounter++;

    let document = JSON.parse(line);
    let indriDoc = "<DOC>\n<DOCNO>" + document.id + "</DOCNO>\n<DOCHDR></DOCHDR>\n<HTML>\n<BODY>\n";
    let contents = document.contents; //array

    contents.forEach(function(c){
        if(c!=null && c.hasOwnProperty("type")){
            if( c.type == 'title' || c.subtype == 'paragraph'){
                indriDoc = indriDoc + " " + c.content;
            }
            if( c.type == 'image'){
                indriDoc = indriDoc + " " + c.fullcaption;
            }
        }
    })
    indriDoc = indriDoc + "\n</BODY>\n</HTML>\n</DOC>\n";

    try {
        fs.appendFileSync(outFile, indriDoc);
        if(lineCounter % 1000 == 0){
            console.log("Line "+lineCounter+" written to file.");
        }
      } catch (err) {
        /* Handle the error */
            throw err;
      }
});
