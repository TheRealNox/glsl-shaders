#version 400 core

// *** Attributes set from client
in vec2			inVertexPos;
in vec2			inTextCoordinate;

// *** Uniforms set from client
uniform mat4	uniMatrix;

// *** Transmit to Fragment stage
out vec2		varTextCoordinate;

void			main()
{
	gl_Position = uniMatrix * vec4(inVertexPos.xy, 0.0, 1.0);
	varTextCoordinate = inTextCoordinate;
}
