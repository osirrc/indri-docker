//@ts-check

"use strict";
let fileToProcess = process.argv[2]; //file
let outFolder = process.argv[3]; //folder
let outFileCounter = 0;

const readline = require('readline');  
const fs = require('fs');  

const readInterface = readline.createInterface({  
    input: fs.createReadStream(fileToProcess, {encoding: 'utf8'})
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
        let outFile = outFolder+"/file"+outFileCounter;
        fs.appendFileSync(outFile, indriDoc);
        if(lineCounter % 10000 == 0){
            console.log("Line "+lineCounter+" written to file.");
            outFileCounter++;
        }
      } catch (err) {
        /* Handle the error */
            throw err;
      }
});
