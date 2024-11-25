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

mat2 rotate2D(float _angle) {
    float s = sin(_angle);
    float c = cos(_angle);
    return mat2(c, -s, s, c);
}

float circle(vec2 _st, float _size, float _thickness, float _smooth){
    _size = _size * 0.5;

    vec2 center = vec2(0.5);
    float dist = distance(_st, center);

    float result = abs(dist - _size);
    result = smoothstep(_thickness, _thickness + _smooth, result);

    return 1. - result;
}

float solid_circle(vec2 _st, float _size, float _smooth){
    _size = _size * 0.5;

    vec2 center = vec2(0.5);
    float dist = distance(_st, center);

    float result = smoothstep(_size, _size + _smooth, dist);

    return 1. - result;
}

float solid_boxes(vec2 _st, float _size, float _smooth){
    _size = 1. - _size;

    vec2 _uv = (_st -0.5) * 2.;
    _uv = abs(_uv);

    vec2 result =  1. - smoothstep( vec2(_size), vec2(_size + _smooth), _uv);

    return result.x * result.y;
}


float boxes(vec2 _st, float _size, float _thickness, float _smooth){
    _size = 1. - _size;

    vec2 _uv = (_st -0.5) * 2.;
    _uv = abs(_uv);

    vec2 result =  1. - smoothstep( vec2(_size), vec2(_size + _smooth), _uv);
    vec2 inside =  1. - smoothstep( vec2(_size - _thickness), vec2(_size + _smooth - _thickness), _uv);

    return (result.x * result.y) - (inside.x * inside.y);
}


float angle_line(vec2 _st, float _angle ,float _thickness, float _smooth, float _len){
    _angle = map_range(_angle, 0., 1., -3.14159, 3.14159);
    
    _st = (_st - vec2(0.5)) * 2.;
    
    vec2 _uv = rotate2D(_angle) * _st;

    float result = abs(_uv.y);
    result = smoothstep(_thickness, _thickness + _smooth, result);

    float len = abs(_uv.x);
    len = smoothstep(_len, _len + _smooth, len);

    return (1. - result) * (1.-len);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float tv_noise(vec2 st){
    float base_noise = white_noise(st + vec2(u_time));

    float lines = sin(st.y * 900.) ;
    float wave = mod((st.y - fract(sin(u_time * .6)) * .5) * 3., 1.);

    return mix(base_noise * lines, wave, .2);
}

void main(void){
    float speed = 20.;
    float size = 24.;
    float smooth_noise = .3;
    float dimp_noise = .5;

    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    float color_xt = (sin(st.x * 7.) +1.) * 0.5;

    vec3 color = mix(
        mix(vec3(1.0, 0.651, 0.0), vec3(1.0, 0.9333, 0.0), color_xt),
        mix(vec3(0.898, 0.3333, 0.9725),vec3(0.1412, 0.8706, 0.9686), color_xt), st.y);

    color = mix(
        hsv2rgb(vec3(st.x * 2., .9, 1.0)),
        hsv2rgb(vec3(1.-st.x, 1., .9)),
        st.y + st.x / 2.
    );

    float noise = simplex_noise(
        floor(
            st * vec2(size)
        ) * smooth_noise
    );
    float move_noise = simplex_noise(
        floor(
            (st + vec2(floor(u_time * -speed) * (1./size))) * vec2(size)
        ) * smooth_noise * 0.1
    );


    vec2 pattern_uv = fract(vec2(size) * st);
    
    float circles = circle(pattern_uv, .7, 0.02,.05);
    float solid_circle = solid_circle(pattern_uv, .7, 0.05);
    float angle_line = angle_line(pattern_uv, move_noise, 0.04,.08,.4);
    float solid_boxes = solid_boxes(pattern_uv, .2, .05);
    float boxes = boxes(pattern_uv, .2, .2, .05);

    float st_noise = step(.7, noise);
    float nd_noise = step(.6, noise) - st_noise;
    float th_noise = step(.4, noise) - st_noise - nd_noise;
    float fo_noise = 1. - st_noise - nd_noise - th_noise;

    vec3 display =
        (vec3(angle_line) + vec3(circles * noise)) * (color*st_noise)
        + (vec3(boxes  * noise) + vec3(angle_line)) * (nd_noise * color)
        + vec3(solid_circle * color * noise * th_noise * dimp_noise)
        + vec3(solid_boxes * color * noise * fo_noise * dimp_noise);

    vec3 tv_noise = vec3(tv_noise(st));

    gl_FragColor = vec4(mix(display, tv_noise, .1),1.);
}