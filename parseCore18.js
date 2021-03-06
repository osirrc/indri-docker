//@ts-check

"use strict";
var striptags = require('striptags');

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
    let indriDoc = "<DOC>\n<DOCNO>" + document.id + "</DOCNO>\n<TEXT>\n";
    let contents = document.contents; //array

    contents.forEach(function(c){
        if(c!=null && c.hasOwnProperty("type")){
            if( c.type == 'title' || c.subtype == 'paragraph'){
                indriDoc = indriDoc + " " + striptags(c.content);
            }
            if( c.type == 'image'){
                indriDoc = indriDoc + " " + striptags(c.fullcaption);
            }
        }
    })
    indriDoc = indriDoc + "</TEXT>\n</DOC>\n";

    try {
        let outFile = outFolder+"/file"+outFileCounter;
        fs.appendFileSync(outFile, indriDoc);
        if(lineCounter % 10000 == 0){
            console.log("Line "+lineCounter+" written to file.");
            outFileCounter++;
        }
      } catch (err) {
        /* Handle the error */
            console.log(err);
            throw err;
      }
});
