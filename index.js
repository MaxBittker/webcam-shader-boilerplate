const { setupOverlay } = require("regl-shader-error-overlay");
setupOverlay();

const regl = require("regl")({ pixelRatio: 0.75 });
const { setupWebcam } = require("./src/regl-webcam");
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
let ct;
let cam = setupWebcam({
  regl,
  done: (webcam, { videoWidth, videoHeight, ctracker }) => {
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
        backBuffer: lastFrame,
        "eyes[0]": () => {
          let positions = ct.getCurrentPosition();
          if (positions) {
            return positions[27];
          } else {
            return [5000, 5000];
          }
        },
        "eyes[1]": () => {
          let positions = ct.getCurrentPosition();
          if (positions) {
            return positions[32];
          } else {
            return [5000, 5000];
          }
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
