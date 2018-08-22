precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform vec2 videoResolution;
uniform vec2 eyes[2];
uniform float m[8]; // midi
float m0 = m[0];
float m1 = m[1];
float m2 = m[2];
float m3 = m[3];
float m4 = m[4];
float m5 = m[5];
float m6 = m[6];
float m7 = m[7];
uniform vec4 bands;

varying vec2 uv;

// clang-format off
#pragma glslify: squareFrame = require("glsl-square-frame")
#pragma glslify: worley2D = require(glsl-worley/worley2D.glsl)
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
vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 18.5453);
}

vec2 pixel = vec2(1.0) / resolution;
vec2 vp = vec2(1.0) / vec2(min(videoResolution.x, videoResolution.y));
vec3 voronoi(in vec2 x) {
  vec2 n = floor(x);
  vec2 f = fract(x);

  vec3 m = vec3(8.0);
  float f2 = 80.0;
  for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
      vec2 g = vec2(float(i), float(j));
      vec2 o = hash(n + g);
      // vec2  r = g - f + o;
      vec2 r = g - f + (0.5 + 0.5 * sin(6.2831 * o));
      float d = dot(r, r);
      if (d < m.x) {
        f2 = m.x;
        m = vec3(d, o);
      } else if (d < f2) {
        f2 = d;
      }
    }

  return vec3(sqrt(m.x), sqrt(f2), m.y + m.z);
}

float dither8x8(vec2 position, float brightness) {
  int x = int(mod(position.x, 8.0));
  int y = int(mod(position.y, 8.0));
  int index = x + y * 8;
  float limit = 0.0;

  if (x < 8) {
    if (index == 0)
      limit = 0.015625;
    if (index == 1)
      limit = 0.515625;
    if (index == 2)
      limit = 0.140625;
    if (index == 3)
      limit = 0.640625;
    if (index == 4)
      limit = 0.046875;
    if (index == 5)
      limit = 0.546875;
    if (index == 6)
      limit = 0.171875;
    if (index == 7)
      limit = 0.671875;
    if (index == 8)
      limit = 0.765625;
    if (index == 9)
      limit = 0.265625;
    if (index == 10)
      limit = 0.890625;
    if (index == 11)
      limit = 0.390625;
    if (index == 12)
      limit = 0.796875;
    if (index == 13)
      limit = 0.296875;
    if (index == 14)
      limit = 0.921875;
    if (index == 15)
      limit = 0.421875;
    if (index == 16)
      limit = 0.203125;
    if (index == 17)
      limit = 0.703125;
    if (index == 18)
      limit = 0.078125;
    if (index == 19)
      limit = 0.578125;
    if (index == 20)
      limit = 0.234375;
    if (index == 21)
      limit = 0.734375;
    if (index == 22)
      limit = 0.109375;
    if (index == 23)
      limit = 0.609375;
    if (index == 24)
      limit = 0.953125;
    if (index == 25)
      limit = 0.453125;
    if (index == 26)
      limit = 0.828125;
    if (index == 27)
      limit = 0.328125;
    if (index == 28)
      limit = 0.984375;
    if (index == 29)
      limit = 0.484375;
    if (index == 30)
      limit = 0.859375;
    if (index == 31)
      limit = 0.359375;
    if (index == 32)
      limit = 0.0625;
    if (index == 33)
      limit = 0.5625;
    if (index == 34)
      limit = 0.1875;
    if (index == 35)
      limit = 0.6875;
    if (index == 36)
      limit = 0.03125;
    if (index == 37)
      limit = 0.53125;
    if (index == 38)
      limit = 0.15625;
    if (index == 39)
      limit = 0.65625;
    if (index == 40)
      limit = 0.8125;
    if (index == 41)
      limit = 0.3125;
    if (index == 42)
      limit = 0.9375;
    if (index == 43)
      limit = 0.4375;
    if (index == 44)
      limit = 0.78125;
    if (index == 45)
      limit = 0.28125;
    if (index == 46)
      limit = 0.90625;
    if (index == 47)
      limit = 0.40625;
    if (index == 48)
      limit = 0.25;
    if (index == 49)
      limit = 0.75;
    if (index == 50)
      limit = 0.125;
    if (index == 51)
      limit = 0.625;
    if (index == 52)
      limit = 0.21875;
    if (index == 53)
      limit = 0.71875;
    if (index == 54)
      limit = 0.09375;
    if (index == 55)
      limit = 0.59375;
    if (index == 56)
      limit = 1.0;
    if (index == 57)
      limit = 0.5;
    if (index == 58)
      limit = 0.875;
    if (index == 59)
      limit = 0.375;
    if (index == 60)
      limit = 0.96875;
    if (index == 61)
      limit = 0.46875;
    if (index == 62)
      limit = 0.84375;
    if (index == 63)
      limit = 0.34375;
  }

  return brightness < limit ? 0.0 : 1.0;
}

vec3 dither8x8(vec2 position, vec3 color) {
  return vec3(1.0) * dither8x8(position, length(color));
}

vec4 dither8x8(vec2 position, vec4 color) {
  return vec4(color.rgb * dither8x8(position, length(color)), 1.0);
}

const int lookupSize = 32;
float errorCarry = m0 * 100. * bands.x;
float getGrayscale(vec2 coords) {
  // vec2 uv = coords / resolution.xy;
  // uv.y = 1.0 - uv.y;
  vec3 sourcePixel = texture2D(webcam, clamp(coords, 0., 1.0)).rgb;
  return luma(sourcePixel);
}
void main() {
  vec2 pos = squareFrame(resolution);
  // vec3 color;
  vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution / videoResolution;
  vec2 flipwcord = vec2(1.) - webcamCoord;
  // flipwcord.x = webcamCoord.x;
  vec2 eye1 = eyes[0] / videoResolution;
  vec2 eye2 = eyes[1] / videoResolution;
  vec2 textCoord = uv * 0.5 + vec2(0.5);
  vec2 closeEye =
      distance(eye1, flipwcord) < distance(eye2, flipwcord) ? eye1 : eye2;
  vec2 suck = -2.0 * pixel * normalize(flipwcord - closeEye) *
              random(uv + t * vec2(1.0));
  vec3 webcamColor = texture2D(webcam, flipwcord).rgb * 0.95;
  float ed = smin(distance(eye1, flipwcord), distance(eye2, flipwcord), 0.01);

  float ifd = distance(eye1, eye2);

  float s = 0.1 * ifd * 4.;
  vec2 mid = (eye1 + eye2) * 0.5;

  float xError = 0.0;
  for (int xLook = 0; xLook < lookupSize; xLook++) {
    float grayscale =
        getGrayscale(flipwcord + vec2(-lookupSize + xLook, 0) * vp);
    grayscale += xError;
    float bit = grayscale >= 0.5 ? 1.0 : 0.0;
    xError = (grayscale - bit) * errorCarry;
  }

  float yError = 0.0;
  for (int yLook = 0; yLook < lookupSize; yLook++) {
    float grayscale =
        getGrayscale(flipwcord + vec2(0, -lookupSize + yLook) * vp);
    grayscale += yError;
    float bit = grayscale >= 0.5 ? 1.0 : 0.0;
    yError = (grayscale - bit) * errorCarry;
  }

  float finalGrayscale = getGrayscale(flipwcord);
  finalGrayscale += xError * 0.5 + yError * 0.5;
  float finalBit = finalGrayscale >= 0.5 ? 1.0 : 0.0;

  // gl_FragColor = vec4(finalGrayscale, finalGrayscale, finalGrayscale, 1);
  gl_FragColor = vec4(finalBit, finalBit, finalBit, 1);

  // gl_FragColor = vec4(vec3(1.0) * getGrayscale(flipwcord), 1.0);
  // gl_FragColor.rgb = ither8x8(flipwcord, vec3(getGrayscale(flipwcord)));

  // float a = t * m6;
  // a += bands.y * m5;
  // vec2 offset = pixel * 50. * vec2(sin(a), cos(a)) * m3 * bands.x;
  // vec3 rgb = texture2D(webcam, flipwcord - offset).rgb * 0.95;
  // vec3 rgb2 = texture2D(webcam, flipwcord + offset).rgb * 0.95;

  vec3 color = vec3(00.0);
  const int nL = 5;
  for (int leaf = 0; leaf < nL; leaf++) {
    float a = float(leaf) * 3.14 * 2. / float(nL);
    a += t * m6;
    vec2 offset =
        pixel * 50. * vec2(sin(a), cos(a)) * m3 * (bands.x - m4 * 0.1);
    vec3 rgb = texture2D(webcam, flipwcord - offset).rgb * 0.95;

    // color = min(color, rgb);
    color = abs(color - rgb);
  }
  color = mod(color, 1.0);
  // gl_FragColor
  // rgb += vec3(1.0) * t * 0.01 - ed;
  // rgb += bands.xyz * m1;
  // rgb = mod(rgb, 1.0);
  // vec3 drgb = dither8x8(gl_FragCoord.xy / 2., rgb);
  // gl_FragColor = vec4(bands.xzy * finalBit, 1.0);
  gl_FragColor = vec4(color, 1.0);
  // gl_FragColor = vec4(abs(rgb - rgb2) * m7, 1.0);
}