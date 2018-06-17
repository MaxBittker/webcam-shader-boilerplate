precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform vec2 videoResolution;
uniform vec2 eyes[2];

varying vec2 uv;

// clang-format off
#pragma glslify: squareFrame = require("glsl-square-frame")

#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: luma = require(glsl-luma)
#pragma glslify: smin = require(glsl-smooth-min)
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
#define PI 3.14159265359

float random(in vec2 _st) {
  return fract(sin(dot(_st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 pixel = vec2(1.0) / resolution;

void main() {

  vec3 color;
  vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution / videoResolution;
  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 eye1 = eyes[0] / videoResolution;
  vec2 eye2 = eyes[1] / videoResolution;
  vec2 textCoord = uv * 0.5 + vec2(0.5);
  vec2 closeEye =
      distance(eye1, flipwcord) < distance(eye2, flipwcord) ? eye1 : eye2;
  vec2 suck = -2.0 * pixel * normalize(flipwcord - closeEye) *
              random(uv + t * vec2(1.0));
  // *(0.5 + noise(vec3(uv * 10., t * 5.)));

  vec3 webcamColor = texture2D(webcam, flipwcord).rgb * 0.95;
  float ed = smin(distance(eye1, flipwcord), distance(eye2, flipwcord), 0.01);

  float ifd = distance(eye1, eye2);

  float s = 0.1 * ifd * 4.;
  vec2 mid = (eye1 + eye2) * 0.5;
  color = vec3(1.0, 0.95, 0.95);

  vec2 ruv = uv;
  float p = 0.1;
  ruv.y = mod(uv.y, p * 1.4);
  float f = 40.;
  // f *= luma(webcamColor)
  ruv.x += luma(webcamColor) * 0.5;
  float wave = (1.0 + sin(t * 0.1 + ruv.x * f)) * p * 0.5;
  if (ruv.y > wave && ruv.y < wave + pixel.y * 15.) {
    color = vec3(0.1, 0.1, 0.4);
  }

  // if (uv.x < -1. + pixel.x * 5.) {
  //   if (mod(t, 20.) > 18.) {
  //     // color = vec3(1., 1., 1.);
  //   } else {
  //     // color = vec3(0.2, 0.3, 0.4);
  //   }
  // } else {
  //   float weight = luma(webcamColor);

  //   float edge = luma(texture2D(webcam, flipwcord - pixel.x).rgb) -
  //                luma(texture2D(webcam, flipwcord + pixel.x).rgb);

  //   edge *= 3.;

  //   if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
  //       mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd * -2.5)
  //       {
  //   } else {
  //     weight *= 0.8;
  //   }
  //   vec2 fall = 2. * pixel * vec2(1., 0) * (0.5 + random(vec2(uv.y, t)) *
  //   0.5) *
  //               (1. - weight);

  //   color = texture2D(backBuffer, textCoord - fall).rgb * 1.0;
  //   if (uv.y < 0.0) {
  //     // color =weight * vec3(1.0);
  //   }
  // }

  // if (ed < s) {
  // distance(mid,flipwcord)<0.2
  if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
      mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd * -2.5) {
    float weight = luma(webcamColor);
    // color = weight * vec3(1.0);
  }
  // if (luma(webcamColor) <
  //  0.4) {
  // 0.5 + 0.2 * noise(vec3(uv * 200., t * 0.1))) {
  // color = vec3(1.);
  // color *= 0.25;
  // }
  gl_FragColor = vec4(color, 1.0);
}