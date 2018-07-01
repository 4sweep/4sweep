hoursparser.js
==============

dumb but useful hours extractor from free-text entry

demo @ http://foursquare.github.io/hoursparser.js/

some examples of the inputs and outputs:

    ([{
      input: 'm-w 10:15am-2am; fri 12pm-11pm;',
      output: /** @type {fourSq.api.models.hours.MachineHours} */ ({
        timeframes: /** @type {Array.<fourSq.api.models.hours.MachineTimeframe>} */ ([
          { days: [1, 2, 3], open: [ { start: '1015', end: '+0200' } ] },
          { days: [5], open: [ { start: '1200', end: '2300' } ] }
        ])
      })
    }, {
      input: 'mon, tues, wednesday 1015-2; f 12:00p until 2300;',
      output: /** @type {fourSq.api.models.hours.MachineHours} */ ({
        timeframes: /** @type {Array.<fourSq.api.models.hours.MachineTimeframe>} */ ([
          { days: [1], open: [ { start: '1015', end: '+0200' } ] },
          { days: [2], open: [ { start: '1015', end: '+0200' } ] },
          { days: [3], open: [ { start: '1015', end: '+0200' } ] },
          { days: [5], open: [ { start: '1200', end: '2300' } ] }
        ])
      })
    }, {
      input: 'mon-tu, w 10:15 A.M.-02h00; f 12:00 until 23:00;',
      output: /** @type {fourSq.api.models.hours.MachineHours} */ ({
        timeframes: /** @type {Array.<fourSq.api.models.hours.MachineTimeframe>} */ ([
          { days: [1, 2], open: [ { start: '1015', end: '+0200' } ] },
          { days: [3], open: [ { start: '1015', end: '+0200' } ] },
          { days: [5], open: [ { start: '1200', end: '2300' } ] }
        ])
      })
    }, {
      input: 'm-f 10-12',
      output: /** @type {fourSq.api.models.hours.MachineHours} */ ({
        timeframes: /** @type {Array.<fourSq.api.models.hours.MachineTimeframe>} */ ([
          { days: [1, 2, 3, 4, 5], open: [ { start: '1000', end: '1200' } ] }
        ])
      })
    }, {
      input: '10:15am-2am m-w; 12pm-11pm fri,su',
      output: /** @type {fourSq.api.models.hours.MachineHours} */ ({
        timeframes: /** @type {Array.<fourSq.api.models.hours.MachineTimeframe>} */ ([
          { days: [1, 2, 3], open: [ { start: '1015', end: '+0200' } ] },
          { days: [5], open: [ { start: '1200', end: '2300' } ] },
          { days: [7], open: [ { start: '1200', end: '2300' } ] }
        ])
      })
    }])
