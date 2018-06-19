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

void main() {
  vec2 pos = squareFrame(resolution);
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
  color = vec3(0.9, 0.89, 0.87);

  vec3 red = vec3(0.9, 0.25, 0.);
  vec3 yellow = vec3(0.95, 0.8, 0.);
  vec3 brown = vec3(0.4, 0.2, 0.1);
  // vec3 hue = red;
  // pos += noise(vec3(pos * 15., 0.5)) * 0.01;
  float m = 100.;
  // for (float c = 0.; c < 3.; c++) {
  //   if (c == 1.) {
  //     hue = yellow;
  //   }
  //   if (c == 2.) {
  //     hue = brown;
  //   }
  //   vec2 vor = worley2D(pos * 10. + vec2(200.) * c, 1.0, false);
  //   float dots = vor.x;
  //   float cell = vor.y;

  //   float dilation = noise(vec3(pos * 2.5 + vec2(200.) * c, t * 0.01));
  //   // dilation = (1.0 - length(abs(webcamColor.rgb * hue)));
  //   // float dd = dots + min(dilation, 0.75) * 1.0;
  //   // dilation = max(dilation, 0.2);
  //   float dd = (cell - dots) * (1.0 - dots * 1.0);
  //   // dd *= max(dilation, 0.3);
  //   dilation = max(0.2 * dd, dilation);
  //   dd *= dilation;
  //   // if (dd > 0.05 && dd < m) {
  //   if (dd > 0.05) {
  //     //  color = hue;
  //   }
  //   // dd = min(dd, m);
  // }
  // vec3 col = 0.5 + 0.5 * cos(vor.y * 6.2831 + vec3(0.0, 1.0, 2.0));
  // col *= clamp(1.0 - 0.4 * vor.x * vor.x, 0.0, 1.0);
  // col -= (1.0 - smoothstep(0.08, 0.09, vor.x));

  // color = red * dots;
  // hsv2rgb(vec3(cell, 0.5, 0.5));
  // m = min(dd, m);
  // }
  // if (dd < 0.1) {
  // }
  vec3 c = voronoi(10.0 * pos);

  // colorize
  float hue = 0.2 + (floor(c.z * 3.) / 9.);
  vec3 col = hsv2rgb(vec3(hue, 0.9, 0.5));
  // 0.5 + 0.5 * cos(c.y * 6.2831 + vec3(0.0, 1.0, 2.0));
  // col *= clamp(1.0 - 0.4 * c.x * c.x, 0.0, 1.0);
  // col -= (1.0 - smoothstep(0.08, 0.09, c.x));
  float dilation = noise(vec3(pos * 1.0 + (vec2(200.) * hue), t * 0.01)) + 0.5;

  // dilation = luma(webcamColor) ;
  float dd = (c.y - c.x) * (1.0 - c.x * 1.0);
  dd *= dilation;
  dd *= 2.;
  if (dd > 0.5 || c.x < 0.05) {
    color = col;
  }
  // color = (c.y - c.x) * col;
  // vec3 cel = cellular(pos * 5.);
  // color = hsv2rgb(

  //     vec3(cel.z / 9., 0.5, 0.5));
  // if (cel.x < 0.05) {
  //   color = vec3(0.);
  // }
  // vec3 col = hsv2rgb(vec3(t + floor(c.y * 1.5) / 5., 0.5, 0.5));

  // if (pos.x < -1. + pixel.x * 5.) {
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
  //       mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd *
  //       -2.5)
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
  // if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
  //     mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd * -2.5)
  //     {
  //   float weight = luma(webcamColor);
  //   // color = weight * vec3(1.0);
  // }
  // if (luma(webcamColor) <
  //  0.4) {
  // 0.5 + 0.2 * noise(vec3(uv * 200., t * 0.1))) {
  // color = vec3(1.);
  // color *= 0.25;
  // }
  gl_FragColor = vec4(color, 1.0);
}