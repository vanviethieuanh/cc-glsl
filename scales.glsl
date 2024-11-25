#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float white_noise(vec2 _st) {
    return fract(sin(dot(_st, vec2(12.9898,78.233))) * 43758.5453);
}

float simplex_noise(vec2 _st){
    vec2 i = floor(_st);
    vec2 f = fract(_st);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(white_noise(i), white_noise(i+vec2(1.0,0.0)), u.x),
               mix(white_noise(i+vec2(0.0,1.0)), white_noise(i+vec2(1.0,1.0)), u.x), u.y);
}

float map_range(float _value, float _inputMin, float _inputMax, float _outputMin, float _outputMax) {
    return (_value - _inputMin) * (_outputMax - _outputMin) / (_inputMax - _inputMin) + _outputMin;
}

float circle(vec2 _st, float _size, float _thickness, float _smooth){
    _size = _size * 0.5;

    vec2 center = vec2(0.5);
    float dist = distance(_st, center);

    float result = abs(dist - _size);
    result = smoothstep(_thickness, _thickness + _smooth, result);

    return 1. - result;
}

float angle_line(vec2 _st, float _angle ,float _thickness, float _smooth){
    float result = abs(atan(_st.y, _st.x) - _angle);
    result = smoothstep(_thickness, _thickness + _smooth, result);


    return 1. - result;
}

void main(void){
    float speed = 15.;
    float size = 30.;
    float smooth_noise = .2;

    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 color = vec3(0.0);

    float noise = simplex_noise(
        floor(
            (st + vec2(floor(u_time * -speed) * (1./size))) * vec2(size)
        ) * smooth_noise
    );

    vec2 pattern_uv = fract(vec2(size) * st);
    float circles = angle_line(pattern_uv, noise,noise*0.02,.1);

    // noise *= step(.5, noise);

    gl_FragColor = vec4(vec3(circles*noise),1.0);
}