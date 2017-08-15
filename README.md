GLSL Shader code:

There is 2 different vertex shaders in this repo:
  passthrough1VT.v.glsl
  passthrough1VT1Matrix.v.glsl

There should be pretty self explanatory but the former is only using 2 attributes, one vec2 for the vertices and one for the texture coordinate. The later add a ModelViewProjection matrix to be apply on the input vertex.

Regarding the fragment shaders, you will find:
  colorConverter.f.glsl
  
This shader will allow to decode/encode on the GPU YUY2 footage (please see here for a good description of YUY2 format: https://www.loc.gov/preservation/digital/formats/fdd/fdd000364.shtml)

It's using subroutines for easier modularity (you can use a single openGL program even if you have different format, just change the subroutines on runtime). In order to change subroutine, on can do as follow:
	
	GLuint indices[this->_colourSubroutines.totalSubroutines]; // Query using openGL glGetProgramStageiv(COLOUR_PROGRAM_ID, GL_FRAGMENT_SHADER, GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS, &this->_colourSubroutines.totalSubroutines);
	
	indices[this->_colourSubroutines.colourConversion.loc] = this->getAppropriateShaderRoutineFromMetadata(metadata, this->_colourSubroutines.colourConversion);	
	//We now set our subroutines index table to the shader stage.
	glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, this->_colourSubroutines.totalSubroutines, indices);

At the moment, this shader allows you to encode/decode from to:
 - LimitedYUY2ToComputerRGB
 - ComputerRGBToLimitedYUY2
 - FullYUY2ToComputerRGB
 - ComputerRGBToFullYUY2
 - SRGBToComputerRGB
 - PassthroughComputerRGB

