shader_type canvas_item;

uniform float shake_intensity = 0.0 ;
uniform float shake_speed = 20.0 ;
//不同的对象只要使用不同的shaderMaterial 文件
//shader代码相同也不不会互相影响（需要开启 Local）
//脚本和编辑器 只能够 控制uniform变量


void vertex() {
	vec2 shake = vec2(0,0) ;

	//使用小于0.0 因为 我们的精灵在x轴上方 也就是y为负的时候
	if (VERTEX.y < 1.0) {
		shake.x = sin(TIME * shake_speed + VERTEX.y ) * shake_intensity;
	}

	VERTEX.xy += shake;
}
