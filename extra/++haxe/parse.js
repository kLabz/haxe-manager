#!/usr/bin/env node

const fs = require('fs');
const haxeErrorParser = require('haxe-error-parser');

const errors = [];
const stdin = fs.readFileSync('/dev/stdin').toString().trim();
if (stdin.length == 0) process.exit(0);

const lines = stdin.split("\n");

lines.forEach(function(l) {
    if (haxeErrorParser.identifyError(l)) {
        errors.push(haxeErrorParser.transform({
            name: 'ModuleError',
            message: l
        }));
    } else {
        errors.push({
            message: l
        });
    }
});

const formattedErrors = haxeErrorParser.format(errors, null, true);
if (formattedErrors.length == 0) process.exit(0);
console.log(...formattedErrors.map(l => "\n" + l));
