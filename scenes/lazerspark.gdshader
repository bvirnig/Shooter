shader_type canvas_item;

void vertex(){
	VERTEX.y += sin(TIME * 10.0) * 200.0 * (UV.x - 1.0);
}