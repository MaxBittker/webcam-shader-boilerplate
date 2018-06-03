precision highp float;
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

float random(in vec2 _st) {
  return fract(sin(dot(_st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 pixel = vec2(1.0) / resolution;

void main() {
  vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution / videoResolution;
  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 eye1 = eyes[0] / videoResolution;
  vec2 eye2 = eyes[1] / videoResolution;
  vec3 color;

  vec2 textCoord = uv * 0.5 + vec2(0.5);
  vec2 closeEye =
      distance(eye1, flipwcord) < distance(eye2, flipwcord) ? eye1 : eye2;
  vec2 suck = -2.0 * pixel * normalize(flipwcord - closeEye) *
              random(uv + t * vec2(1.0));
  // *(0.5 + noise(vec3(uv * 10., t * 5.)));
  vec2 fall = 5. * pixel * vec2(0, -1.0) * random(uv + t * vec2(1.0));
  vec3 color2 = texture2D(backBuffer, textCoord - fall).rgb * 1.0;

  vec3 webcamColor = texture2D(webcam, flipwcord).rgb * 0.95;
  float ed = smin(distance(eye1, flipwcord), distance(eye2, flipwcord), 0.01);

  float ifd = distance(eye1, eye2);
  float s = 0.1 * ifd * 4.;
  vec2 mid = (eye1 + eye2) * 0.5;
  // if (ed < s) {
  if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
      mid.y - flipwcord.y < ifd * 0.2 * sin(t * 0.04)) {
    float weight = luma(webcamColor);
    color = color2;
  } else {
    float weight = luma(webcamColor);
    color = weight * vec3(0.8, 0.8, 1.0);
  }

  gl_FragColor = vec4(color, 1.0);
}