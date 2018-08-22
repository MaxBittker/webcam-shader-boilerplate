let clmtrackr = require("clmtrackr");
let ctracker = new clmtrackr.tracker();
ctracker.init();

// const getUserMedia = require("getusermedia");

// function audioAnalyzer(options) {
//   const regl = options.regl;

// getUserMedia({ audio: true }, function(err, stream) {
//   if (err) {
//     options.error && options.error(err);
//     return;
//   }

//   //
//   var context = new AudioContext();
//   var analyser = context.createAnalyser({
//     fftSize: 512,
//     smoothingTimeConstant: 0.5
//   });
//   let source = context.createMediaStreamSource(stream);
//   source.connect(analyser);
//   // regl.frame(() => webcam.subimage(video));
//   // options.done(analyser, {});
// });
// }

// module.exports = { audioAnalyzer };

function setupWebcam(options) {
  const regl = options.regl;
  var video = null;
  var canvas = null;

  function startup() {
    video = document.getElementById("video");
    canvas = document.getElementById("canvas");
    let startbutton = document.getElementById("start");

    var trackingStarted = false;

    function tryGetUserMedia() {
      navigator.mediaDevices
        .getUserMedia({
          video: true,
          audio: true
        })
        .then(gumSuccess)
        .catch(e => {
          console.log("initial gum failed");
          console.log(e);
        });
      video.play();
      startbutton.hidden = true;
    }

    tryGetUserMedia();

    startbutton.onclick = function() {
      console.log("play!");
      tryGetUserMedia();
    };

    function gumSuccess(stream) {
      var context = new AudioContext();
      var analyser = context.createAnalyser({
        fftSize: 256,
        smoothingTimeConstant: 0.5
      });
      let source = context.createMediaStreamSource(stream);
      source.connect(analyser);

      if ("srcObject" in video) {
        video.srcObject = stream;
      } else {
        video.src = window.URL && window.URL.createObjectURL(stream);
      }
      video.onloadedmetadata = function() {
        console.log("metadata loaded");
        const webcam = regl.texture(video);

        const { videoWidth, videoHeight } = video;

        var w = videoWidth;
        var h = videoHeight;
        video.height = h;
        video.width = w;
        video.volume = 0;
        ctracker.init();
        ctracker.start(video);
        // positionLoop();

        regl.frame(() => webcam.subimage(video));
        options.done(webcam, {
          audio: analyser,
          videoWidth,
          videoHeight,
          ctracker
        });
      };
    }

    video.addEventListener(
      "canplay",
      function(ev) {
        video.play();
      },
      false
    );
  }

  window.onload = startup;
}

module.exports = { setupWebcam };
