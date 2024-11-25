// Try to recreate Hinata Sakaguchi (That Time I Got Reincarnated as a Slime) slash effect but in circle

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359;

float map(float value,float min1,float max1,float min2,float max2){
    return min2+(value-min1)*(max2-min2)/(max1-min1);
}

void main(){
    float radius=.908;
    float thickness=.237;
    float point=3.;
    
    vec2 uv=gl_FragCoord.xy/u_resolution.xy;
    vec2 center=uv*2.-1.;
    
    float angle=atan(center.x,center.y);
    angle=map(angle,-PI,PI,0.,1.);
    
    gl_FragColor=vec4(angle);
}
