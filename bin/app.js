#!/usr/bin/env node
'use strict';

var _ = require('lodash'),
    buntstift = require('buntstift'),
    findSuggestions = require('findsuggestions'),
    program = require('commander');

var assertCommandArgument = require('./assertCommandArgument'),
    packageJson = require('../package.json');

buntstift.noColor();
buntstift.noUtf();

program.
  version(packageJson.version).
  on('*', function (argv) {
    var suggestions = findSuggestions({
      for: argv[0],
      in: _.pluck(this.commands, '_name')
    });

    if (suggestions[0].similarity === 1) {
      return;
    }

    buntstift.error('Unknown command {{specified}}, did you mean {{suggested}}?', {
      specified: argv[0],
      suggested: suggestions[0].suggestion
    });
    buntstift.exit(1);
  }).
  parse(process.argv);

assertCommandArgument(program);
