precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;

uniform vec4 bands;

varying vec2 uv;

// clang-format off
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
#define PI 3.14159265359

float random(in vec2 _st) {
  return fract(sin(dot(_st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}
vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 18.5453);
}

vec2 pixel = vec2(1.0) / resolution;
vec2 vp = vec2(1.0) / vec2(min(videoResolution.x, videoResolution.y));
float maxd(vec2 i) { return max(abs(i.x), abs(i.y)); }
void main() {
  vec2 uvN = (uv * 0.5) + vec2(0.5);
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = uv / resRatio;

  webcamCoord /= 2.0;
  webcamCoord += vec2(0.5);

  vec2 flipwcord = vec2(1.) - webcamCoord;

  vec3 webcamColor = texture2D(webcam, flipwcord).rgb;

  vec3 backBufferColor = texture2D(backBuffer, uvN).rgb;

  gl_FragColor = vec4(webcamColor, 1);
}