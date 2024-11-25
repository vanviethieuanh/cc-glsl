// Author @patriciogv ( patriciogonzalezvivo.com ) - 2015

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

mat2 scale2D(vec2 _scale){
    return mat2(_scale.x,0.,0.,_scale.y);
}

vec2 brickTile(vec2 _st,float _zoom){
    _st*=_zoom;
    
    // Here is where the offset is happening
    _st.x+=step(1.,mod(_st.y,2.))*mod(u_time,1.)*floor(mod(u_time,2.));
    _st.x+=(1.-step(1.,mod(_st.y,2.)))*-mod(u_time,1.)*floor(mod(u_time,2.));
    
    _st.y+=step(1.,mod(_st.x,2.))*mod(u_time,1.)*(1.-floor(mod(u_time,2.)));
    _st.y+=(1.-step(1.,mod(_st.x,2.)))*-mod(u_time,1.)*(1.-floor(mod(u_time,2.)));
    
    return fract(_st);
}

float box(vec2 _st,vec2 _size){
    vec2 uv=smoothstep(_size,_size+.1,vec2(distance(_st,vec2(.5))));
    return uv.x*uv.y;
}

void main(void){
    vec2 st=gl_FragCoord.xy/u_resolution.xy;
    vec3 color=vec3(0.);
    
    // Modern metric brick of 215mm x 102.5mm x 65mm
    // http://www.jaharrison.me.uk/Brickwork/Sizes.html
    // st /= vec2(2.15,0.65)/1.5;
    
    float scale=20.;
    float speed=.1;
    
    // vec2 offset = vec2(u_time * speed * (mod(floor(st.y * scale), 2.)-.5) * 2.,0.);
    
    // Apply the brick tiling
    st=brickTile(st,scale);
    
    color=vec3(box(st,vec2((sin(u_time)+1.)/8.)));
    
    // Uncomment to see the space coordinates
    // color = vec3(st,0.0);
    
    gl_FragColor=vec4(color,1.);
}
