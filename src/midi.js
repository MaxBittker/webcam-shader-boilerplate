let nanoKONTROL = require("korg-nano-kontrol");

let data = {};
for (var i = 0; i < 8; i++) {
  data[i] = {
    knob: 1.0,
    slider: 1.0,
    s: false,
    m: false,
    r: false
  };
}
nanoKONTROL
  .connect()
  .then(function(device) {
    console.log("connected!" + device.name);
    setupHandlers(device);
  })
  .catch(function(err) {
    console.error(err);
  });

const column = s => parseInt(s.split(":")[1], 0);
const eventType = s => s.split(":")[0];

function storeScalar(value) {
  let c = column(this.event);
  let type = eventType(this.event);
  data[c][type] = value;
}
const buttonType = s => s.split(":")[1];
const buttonColumn = s => parseInt(s.split(":")[2], 0);

function storeButton(value) {
  let c = buttonColumn(this.event);
  let type = buttonType(this.event);
  if (value) {
    data[c][type] = !data[c][type];
  }
}
function setupHandlers(device) {
  // catch all slider/knob/button events
  device.on("slider:*", storeScalar);
  device.on("knob:*", storeScalar);
  device.on("button:**", storeButton);
}

function getMidiValue(n) {
  let { knob, slider, s, m, r } = data[n];
  //   console.log(knob, slider, s, m, r);
  knob /= 127;
  slider /= 127;
  slider -= 0.5;

  knob = Math.pow(knob, 6) * 255;

  value = knob * slider;

  if (s) {
    value /= 10;
  }
  if (m) {
    value *= 10;
  }
  if (r) {
    value = 0;
  }

  return value;
}
module.exports = { getMidiValue };
