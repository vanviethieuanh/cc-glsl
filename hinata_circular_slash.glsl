// Try to recreate Hinata Sakaguchi (That Time I Got Reincarnated as a Slime) slash effect but in circle

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float glow(float map,float b){
    return abs((1./(1.+pow(2.71828182846,b*map)))-.5);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K=vec4(1.,2./3.,1./3.,3.);
    vec3 p=abs(fract(c.xxx+K.xyz)*6.-K.www);
    return c.z*mix(K.xxx,clamp(p-K.xxx,0.,1.),c.y);
}

void main(){
    float radius=.908;
    float thickness=.237;
    float point=3.;
    
    vec2 uv=gl_FragCoord.xy/u_resolution.xy;
    vec2 center=uv*2.-1.;
    
    vec2 pos=vec2(.5)-uv;
    float angle=atan(pos.y,pos.x);
    float f=cos(angle*.5+u_time);
    f=1.-glow(f,10.);
    f=smoothstep(.4,1.,f);
    
    float dis=length(center);
    float circle=abs(dis-radius);
    float glow_circle=1.-pow(circle,.4);
    
    glow_circle=smoothstep(.608,.984,glow_circle);
    
    circle=step(thickness,circle);
    circle=1.-circle;
    
    vec3 col=vec3((sin(angle)+1.)*.5,1.-f*.832,1.);
    col=hsv2rgb(col);
    
    vec4 color=vec4(col,1.);
    
    gl_FragColor=vec4(f*glow_circle)*color;
}
