precision mediump float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;

varying vec2 uv;

// clang-format off
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
// clang-format on

void main() {
  vec3 color;
  float r = abs(sin(t / 25.));
  if (length(uv) < r && length(uv) > r - 0.1) {
    color = hsv2rgb(vec3(sin(t * 0.01), 0.5, 0.5));
  } else {
    vec2 textCoord = (uv * 0.5) + vec2(0.5);
    color = texture2D(backBuffer, textCoord).rgb * 0.95;
  }
  gl_FragColor = vec4(color, 1.0);
}