#version 400 core

// *** Attributes coming from Vertex stage
in vec2				varTextCoordinate;

// *** Sampler inputs set from client
uniform sampler2D	uniFrame;

// *** Subroutines
subroutine vec4		convertFrameToRGB();
subroutine uniform	convertFrameToRGB colourConverter;

// *** Output
out vec4 fragColor;

vec4 inYUY2(vec4 tempyuv, float isOdd)
{
	if (isOdd > 0.0)
		return vec4(tempyuv.b, tempyuv.g, tempyuv.a, 255.0);
	else
		return vec4(tempyuv.r, tempyuv.g, tempyuv.a, 255.0);
}

vec4 inUYVY(vec4 tempyuv, float isOdd)
{
	if (isOdd > 0.0)
		return vec4(tempyuv.a, tempyuv.r, tempyuv.b, 255.0);
	else
		return vec4(tempyuv.g, tempyuv.r, tempyuv.b, 255.0);
}

vec4 limitedYCbCrToComputerRGBNormalized(vec4 yuv)
{
	vec4 rgb = vec4(0.0);
	float scale = 1.0f / 256.0f;
	
	yuv = yuv * 255.0;
	
	yuv.r -= 16.0;
	yuv.g -= 128.0;
	yuv.b -= 128.0;
	
	rgb.r = scale * ((298.082 * yuv.r) + (458.942 * yuv.b));
	rgb.g = scale * ((298.082 * yuv.r) + (-54.592 * yuv.g) + (-136.425 * yuv.b));
	rgb.b = scale * ((298.082 * yuv.r) + (540.775 * yuv.g));
	
	rgb.a = 255.0f;
	
	rgb = rgb / 255.0f;
	
	return rgb;
}

vec4 computerRGBToPackedLimitedYCbCr(vec4 firstRGB, vec4 secondRGB)
{
	float scale = 1.0f / 256.0f;
	vec4 packedYUYV = vec4(0.0);
	firstRGB = firstRGB * 255.0f;
	secondRGB = secondRGB * 255.0f;
	
	//Y
	packedYUYV.r = 16.0 + (scale * ((46.742 * firstRGB.r) + (157.243 * firstRGB.g) + (15.874 * firstRGB.b)));
	//U
	packedYUYV.g = 128.0 + (scale * ((-25.765 * firstRGB.r) + (-86.674 * firstRGB.g) + (112.439 * firstRGB.b)));
	//Y'
	packedYUYV.b = 16.0 + (scale * ((46.742 * secondRGB.r) + (157.243 * secondRGB.g) + (15.874 * secondRGB.b)));
	//V
	packedYUYV.a = 128.0 + (scale * ((112.439 * firstRGB.r) + (-102.129 * firstRGB.g) + (-10.310 * firstRGB.b)));
	
	packedYUYV = packedYUYV / 255.0f;
	
	return packedYUYV;
}

vec4 fullYCbCrToComputerRGBNormalized(vec4 yuv)
{
	vec4 rgb = vec4(0.0);
	float scale = 1.0f / 256.0f;
	
	yuv = yuv * 255.0;
	
	yuv.g -= 128.0;
	yuv.b -= 128.0;
	
	rgb.r = scale * ((256.0 * yuv.r) + (403.1488 * yuv.b));
	rgb.g = scale * ((256.0 * yuv.r) + (-47.954944 * yuv.g) + (-119.839744 * yuv.b));
	rgb.b = scale * ((256.0 * yuv.r) + (475.0336 * yuv.g));
	
	rgb.a = 255.0f;
	
	rgb = rgb / 255.0f;
	
	return rgb;
}

vec4 computerRGBToPackedFullYCbCr(vec4 firstRGB, vec4 secondRGB)
{
	float scale = 1.0f / 256.0f;
	vec4 packedYUYV = vec4(0.0);
	firstRGB = firstRGB * 255.0f;
	secondRGB = secondRGB * 255.0f;
	
	//Y
	packedYUYV.r = (scale * ((54.4256 * firstRGB.r) + (183.0912 * firstRGB.g) + (18.4832 * firstRGB.b)));
	//U
	packedYUYV.g = 128.0 + (scale * ((-29.330432 * firstRGB.r) + (-98.669568 * firstRGB.g) + (128.0 * firstRGB.b)));
	//Y'
	packedYUYV.b = (scale * ((54.4256 * secondRGB.r) + (183.0912 * secondRGB.g) + (18.4832 * secondRGB.b)));
	//V
	packedYUYV.a = 128.0 + (scale * ((128.0 * firstRGB.r) + (-116.263168 * firstRGB.g) + (-11.736832 * firstRGB.b)));
	
	packedYUYV = packedYUYV / 255.0f;
	
	return packedYUYV;
}

//
// YUY2 (Packed YCbCr 709-219) to Computer RGB
//
subroutine (convertFrameToRGB)
vec4 convertLimitedYUY2toComputerRGB()
{
	vec4 tempyuv = vec4(0.0);
	vec2 textureRealSize = textureSize(uniFrame, 0);
	
	vec2 pixelPos = vec2(textureRealSize.x * varTextCoordinate.x, textureRealSize.y * varTextCoordinate.y);
	
	float isOdd = floor(mod(pixelPos.x, 2.0));
	
	vec2 packedCoor = vec2(varTextCoordinate.x/2.0, varTextCoordinate.y);
	
	tempyuv = inYUY2(texture(uniFrame, packedCoor), isOdd);
	
	return limitedYCbCrToComputerRGBNormalized(tempyuv);
}

//
// Computer RGB to YUY2 (Packed YCbCr 709-219)
//
subroutine (convertFrameToRGB)
vec4 convertComputerRGBToLimitedYUY2()
{
	vec4 packedYUYV = vec4(0.0);
	
	//De-normalized the size and position to avoid division.
	vec2 textureRealSize = textureSize(uniFrame, 0);
	vec2 realPos = vec2(textureRealSize.x * varTextCoordinate.x, textureRealSize.y * varTextCoordinate.y);
	
	realPos.x -= 0.25;//We want pixel not texel
	
	realPos.y -= 0.25;
	
	if (realPos.y * 2.0 < textureRealSize.y)
	{
		vec2 firstRGBPos = vec2(0.0);
		vec2 secondRGBPos = vec2(0.0);
		vec4 firstRGB = vec4(0.0);
		vec4 secondRGB = vec4(0.0);
		
		if (realPos.x * 2.0 < textureRealSize.x)
		{
			firstRGBPos = vec2(realPos.x * 2.0, realPos.y * 2.0);
			secondRGBPos = vec2(firstRGBPos.x + 1.0, firstRGBPos.y);
		}
		else
		{
			firstRGBPos = vec2((realPos.x * 2.0 - textureRealSize.x), realPos.y * 2.0 + 1.0);
			secondRGBPos = vec2(firstRGBPos.x + 1.0, firstRGBPos.y);
		}
		
		//Normalize then again.
		firstRGBPos.x = firstRGBPos.x / textureRealSize.x;
		firstRGBPos.y = firstRGBPos.y / textureRealSize.y;
		secondRGBPos.x = secondRGBPos.x / textureRealSize.x;
		secondRGBPos.y = secondRGBPos.y / textureRealSize.y;
		
		//Fetching the 2 needed RGB
		firstRGB = texture(uniFrame, firstRGBPos);
		secondRGB = texture(uniFrame, secondRGBPos);
		
		packedYUYV = computerRGBToPackedLimitedYCbCr(firstRGB, secondRGB);
	}
	
	return packedYUYV;
}

//
// YUY2 (YUV Packed 709 255) to Computer RGB
//
subroutine (convertFrameToRGB)
vec4 convertFullYUY2toComputerRGB()
{
	vec4 tempyuv = vec4(0.0);
	vec2 textureRealSize = textureSize(uniFrame, 0);
	
	vec2 pixelPos = vec2(textureRealSize.x * varTextCoordinate.x, textureRealSize.y * varTextCoordinate.y);
	
	float isOdd = floor(mod(pixelPos.x, 2.0));
	
	vec2 packedCoor = vec2(varTextCoordinate.x/2.0, varTextCoordinate.y);
	
	tempyuv = inYUY2(texture(uniFrame, packedCoor), isOdd);
	
	return fullYCbCrToComputerRGBNormalized(tempyuv);
}

//
// Computer RGB to YUY2 (YUV Packed 709 255)
//
subroutine (convertFrameToRGB)
vec4 convertComputerRGBToFullYUY2()
{
	vec4 packedYUYV = vec4(0.0);
	
	//De-normalized the size and position to avoid division.
	vec2 textureRealSize = textureSize(uniFrame, 0);
	vec2 realPos = vec2(textureRealSize.x * varTextCoordinate.x, textureRealSize.y * varTextCoordinate.y);
	
	realPos.x -= 0.25;//We want pixel not texel
	
	realPos.y -= 0.25;
	
	if (realPos.y * 2.0 < textureRealSize.y)
	{
		vec2 firstRGBPos = vec2(0.0);
		vec2 secondRGBPos = vec2(0.0);
		vec4 firstRGB = vec4(0.0);
		vec4 secondRGB = vec4(0.0);
		
		if (realPos.x * 2.0 < textureRealSize.x)
		{
			firstRGBPos = vec2(realPos.x * 2.0, realPos.y * 2.0);
			secondRGBPos = vec2(firstRGBPos.x + 1.0, firstRGBPos.y);
		}
		else
		{
			firstRGBPos = vec2((realPos.x * 2.0 - textureRealSize.x), realPos.y * 2.0 + 1.0);
			secondRGBPos = vec2(firstRGBPos.x + 1.0, firstRGBPos.y);
		}
		
		//Normalize then again.
		firstRGBPos.x = firstRGBPos.x / textureRealSize.x;
		firstRGBPos.y = firstRGBPos.y / textureRealSize.y;
		secondRGBPos.x = secondRGBPos.x / textureRealSize.x;
		secondRGBPos.y = secondRGBPos.y / textureRealSize.y;
		
		//Fetching the 2 needed RGB
		firstRGB = texture(uniFrame, firstRGBPos);
		secondRGB = texture(uniFrame, secondRGBPos);
		
		packedYUYV = computerRGBToPackedFullYCbCr(firstRGB, secondRGB);
	}
	
	return packedYUYV;
}

//SRGBtoComputerRGB
subroutine (convertFrameToRGB)
vec4 convertStudioRGBtoComputeRGB()
{
	vec4 toStretch = vec4(0.0, 0.0, 0.0, 1.0);
	toStretch = texture(uniFrame, varTextCoordinate);
	toStretch *= 255.f;
	toStretch -= 16;
	toStretch *= (255.0/219.0);
	toStretch /= 255.f;
	return toStretch;
}

//Passthrough
subroutine (convertFrameToRGB)
vec4 passthroughComputeRGB()
{
	return texture(uniFrame, varTextCoordinate);
}

void main()
{
	//Convert the frame data from wathever to computer RGB
	fragColor = colourConverter();
}
