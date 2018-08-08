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

void main() {
  vec2 pos = squareFrame(resolution) * 00.5;
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

  color = vec3(0.09, 0.089, 0.087);

  vec3 red = vec3(0.9, 0.25, 0.);
  vec3 yellow = vec3(0.85, 0.7, 0.);
  vec3 brown = vec3(0.4, 0.2, 0.1);
  // vec3 hue = red;
  float m = 100.;
  // pos += noise(vec3(pos * 15., 0.5)) * 0.01;
  vec3 c = voronoi((40.0 + 5. * noise(vec3(pos * 0.1, 0.))) * pos);

  // colorize
  vec3 col = red;
  float h = 0.;
  if (c.z < 1.2) {
    h = 1.;
  }
  if (c.z < 0.7) {
    h = 2.;
  }
  // col += c.x * 0.5;
  // vec3 col = hsv2rgb(vec3(hue, 0.4, 0.6));
  // 0.5 + 0.5 * cos(c.y * 6.2831 + vec3(0.0, 1.0, 2.0));
  // col *= clamp(1.0 - 0.4 * c.x * c.x, 0.0, 1.0);
  // col -= (1.0 - smoothstep(0.08, 0.09, c.x));
  col = hsv2rgb(vec3(0.0, 1.0, 0.9));
  if (c.z < 1.2) {
    col = hsv2rgb(vec3(0.1, 0.9, 0.9));
  }
  if (c.z < 0.7) {
    col = hsv2rgb(vec3(0.05, 0.9, 0.35));
  }
  vec2 spos = pos += noise(vec3(pos * 1., 0.5 + t * 0.001)) * 0.5;
  // spos *= 0.1;
  float dilation =
      noise(vec3((spos * vec2(1.0, 5.)) + vec2(0., t * 0.01) + (vec2(0.3) * h),
                 t * 0.01)) +
      0.3;

  // dilation = 1.0 - abs(length(webcamColor - col));
  float dd = (c.y - c.x) * (1.0 - c.x * 1.0);
  dd *= dilation;
  dd *= 1.5;

  col = hsv2rgb(vec3(0.6, 1.0 - (dilation * 0.3) - c.x * 0.2, 0.7));
  if (c.z < 1.2) {
    col = hsv2rgb(vec3(0.2, 0.6 - dilation * 0.2, 0.9));
  }
  if (c.z < 0.7) {
    col = hsv2rgb(vec3(0.1, 0.9, 0.85));
  }

  if (dd > 0.4 || c.x < 0.05) {
    color = col;
  } else {
    color += col * 0.001;
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
  vec2 st = gl_FragCoord.xy / resolution.xy;
  st.x *= resolution.x / resolution.y;
  vec3 rgb = webcamColor;
  rgb += vec3(1.0) * t * 0.01 - ed;
  ;
  // * st.y + eye1.x * 10.; // t * -0.01;
  rgb = mod(rgb, 1.0);
  vec3 drgb = dither8x8(gl_FragCoord.xy / 2., rgb);
  gl_FragColor = vec4(drgb, 1.0);
  // gl_FragColor = vec4(color, 1.0);
}