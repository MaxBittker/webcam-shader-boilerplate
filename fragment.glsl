precision mediump float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform vec2 videoResolution;
uniform vec2 eyes[2];

varying vec2 uv;

// clang-format off
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: luma = require(glsl-luma)
#pragma glslify: smin = require(glsl-smooth-min)
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
vec2 pixel = vec2(1.0) / resolution;

void main() {
  vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution / videoResolution;
  vec3 webcamColor = texture2D(webcam, vec2(1.) - webcamCoord).rgb * 0.95;

  vec3 color;

  float ed =
      smin(distance(eyes[0] / videoResolution, vec2(1.) - webcamCoord),
           distance(eyes[1] / videoResolution, vec2(1.) - webcamCoord), 0.1);
  
  // float r = length(pos)*2.0;
  // float a = atan(pos.y,pos.x);

  if (ed < 0.05) {
    float weight = luma(webcamColor);
    color = weight * vec3(0.8, 0.8, 0.9) * (0.05 - ed) * 100. ;
    color+= sin(ed  * 100. + t * 0.1) * vec3(0.6,0.1,0.1);
  } else {
    float weight = luma(webcamColor);
    color = weight * vec3(0.8, 0.8, 0.9);

  }
  // vec2 textCoord = uv * 0.5 + vec2(0.5);
  // color =
      // max(color,
      //  texture2D(backBuffer, textCoord + vec2(0, 1.0) * pixel).rgb *1.0);
                    //  1.0 * (1. + fbm3d(vec3(uv, t * 0.05), 5)));

  gl_FragColor = vec4(color, 1.0);
}