#version 400 core

// *** Attributes set from client
in vec2			inVertexPos;
in vec2			inTextCoordinate;

// *** Transmit to Fragment stage
out vec2		varTextCoordinate;

void			main()
{
	gl_Position = vec4(inVertexPos.x, inVertexPos.y, 0.0, 1.0);
	varTextCoordinate = inTextCoordinate;
}
