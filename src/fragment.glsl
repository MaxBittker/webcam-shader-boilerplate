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

  vec3 color2 = texture2D(backBuffer, textCoord + suck).rgb * 0.95;

  vec3 webcamColor = texture2D(webcam, flipwcord).rgb * 0.95;
  float ed = smin(distance(eye1, flipwcord), distance(eye2, flipwcord), 0.1);

  // float r = length(pos)*2.0;
  // float a = atan(pos.y,pos.x);
  float s = 0.1 * distance(eye1, eye2) * 4.;
  if (ed < s) {
    float weight = luma(webcamColor);
    // color = weight * vec3(0.8, 0.8, 0.9) * (s - ed) * 10.;
    // color += sin(ed * 100. + t * 0.1) * vec3(0.6, 0.1, 0.1);
    color = color2;
    // color = weight * vec3(0.8, 0.8, 0.9);

    // max(color, color2 * 0.999);
  } else {
    float weight = luma(webcamColor);
    // color = webcamColor;
    color = weight * vec3(0.8, 0.8, 1.0);
    // color = webcamColor;
  }

  gl_FragColor = vec4(color, 1.0);
}