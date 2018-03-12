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
// clang-format on
vec2 pixel = vec2(1.0) / resolution;

void main() {
  vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution/videoResolution;
  vec3 webcamColor = texture2D(webcam, vec2(1.) - webcamCoord).rgb * 0.95;

  vec3 color;
  // float colorBand = sin((t - uv.y * 25.) / 9.) + 1.0;
  // float weight = luma(webcamColor);
  float ed = min(
    distance(eyes[0]/videoResolution,vec2(1.)- webcamCoord),
    distance(eyes[1]/videoResolution, vec2(1.)-webcamCoord)
  );
  if(ed<0.05){
    color = vec3(sin((ed*100.)+(t*0.1)));
  }else{
    // color = webcamColor;
    float weight = luma(webcamColor);
    color = weight * vec3(0.8, 0.8, 0.9);
  }
  // if (weight > colorBand && weight < colorBand + 0.1) {
    // color = weight * vec3(sin(t), 0.8, 0.5);
  // } else {
  // vec2 textCoord = uv * 0.5 + vec2(0.5);
    // color = texture2D(backBuffer, textCoord + vec2(0,1.0)*pixel).rgb * 1.;
  gl_FragColor = vec4(color, 1.0);
}