const { setupOverlay } = require("regl-shader-error-overlay");
setupOverlay();

const regl = require("regl")({ pixelRatio: 0.75 });
const { setupWebcam } = require("./src/regl-webcam");
let { getMidiValue } = require("./src/midi");

let shaders = require("./src/pack.shader.js");
let vert = shaders.vertex;
let frag = shaders.fragment;

shaders.on("change", () => {
  console.log("update");
  vert = shaders.vertex;
  frag = shaders.fragment;
  let overlay = document.getElementById("regl-overlay-error");
  overlay && overlay.parentNode.removeChild(overlay);
});

const lastFrame = regl.texture();
const pixels = regl.texture();
let audioBuffer = null;

let ct;
let last27 = [0, 0];
let last32 = [0, 0];
let cam = setupWebcam({
  regl,
  done: (webcam, { audio, videoWidth, videoHeight, ctracker }) => {
    ct = ctracker;
    window.ct = ct;
    console.log(ct);
    // console.log(ctracker.getCurrentPosition())
    // console.log(ctracker.getCurrentPosition())
    let drawTriangle = regl({
      uniforms: {
        webcam,
        videoResolution: [videoWidth, videoHeight],
        // Becomes `uniform float t`  and `uniform vec2 resolution` in the shader.
        t: ({ tick }) => tick,
        resolution: ({ viewportWidth, viewportHeight }) => [
          viewportWidth,
          viewportHeight
        ],
        scaledVideoResolution: ({ viewportWidth: vW, viewportHeight: vH }) => {
          let i;
          return (i =
            vW / vH > videoWidth / videoHeight
              ? [videoWidth * (vH / videoHeight), vH]
              : [vW, videoHeight * (vW / videoWidth)]);
        },
        backBuffer: lastFrame,
        "eyes[0]": () => {
          let positions = ct.getCurrentPosition();
          if (positions) {
            last27 = positions[27];
            return positions[27];
          } else {
            return last27;
          }
        },
        "eyes[1]": () => {
          let positions = ct.getCurrentPosition();
          if (positions) {
            last32 = positions[32];
            return positions[32];
          } else {
            return last32;
          }
        },
        "m[0]": () => getMidiValue(0),
        "m[1]": () => getMidiValue(1),
        "m[2]": () => getMidiValue(2),
        "m[3]": () => getMidiValue(3),
        "m[4]": () => getMidiValue(4),
        "m[5]": () => getMidiValue(5),
        "m[6]": () => getMidiValue(6),
        "m[7]": () => getMidiValue(7),
        bands: () => {
          let bands = new Array(4);
          var k = 0;
          var f = 0.0;
          var a = 5,
            b = 11,
            c = 24,
            d = 512,
            i = 0;
          for (; i < a; i++) f += audioBuffer[i];
          f *= 0.2; // 1/(a-0)
          f *= 0.003921569; // 1/255
          bands[0] = f;
          f = 0.0;
          for (; i < b; i++) f += audioBuffer[i];
          f *= 0.166666667; // 1/(b-a)
          f *= 0.003921569; // 1/255
          bands[1] = f;
          f = 0.0;
          for (; i < c; i++) f += audioBuffer[i];
          f *= 0.076923077; // 1/(c-b)
          f *= 0.003921569; // 1/255
          bands[2] = f;
          f = 0.0;
          for (; i < d; i++) f += audioBuffer[i];
          f *= 0.00204918; // 1/(d-c)
          f *= 0.003921569; // 1/255
          bands[3] = f;
          return bands;
        }
        // Many datatypes are supported here.
        // See: https://github.com/regl-project/regl/blob/gh-pages/API.md#uniforms
      },

      frag: () => shaders.fragment,
      vert: () => shaders.vertex,
      attributes: {
        // Full screen triangle
        position: [[-1, 4], [-1, -1], [4, -1]]
      },
      // Our triangle has 3 vertices
      count: 3
    });

    regl.frame(function(context) {
      window.a = audio;

      if (!audioBuffer) {
        audioBuffer = new Uint8Array(audio.frequencyBinCount);
      }
      audio.getByteFrequencyData(audioBuffer);

      regl.clear({
        color: [0, 0, 0, 1]
      });
      drawTriangle();
      lastFrame({
        copy: true
      });
    });
  }
});
