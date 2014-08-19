shader = {}

shader.desaturate = {
  shader = love.graphics.newShader([[
    extern number factor;
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
    {
      vec4 pixel = Texel(tex, tc);
      number average = (pixel.r + pixel.g + pixel.b) / 3;
      pixel.r = pixel.r + (average - pixel.r) * factor;
      pixel.g = pixel.g + (average - pixel.g) * factor;
      pixel.b = pixel.b + (average - pixel.b) * factor;
      
      return pixel * color;
    }  
  ]])
}

function shader.desaturate:setFactor(factor)
  factor = factor or self.factor
  self.shader:send('factor', factor)
end  
 
function shader.desaturate.set()
  love.graphics.setShader(shader.desaturate.shader)
end

shader.blur = {
	vertical = love.graphics.newShader([[
		extern number height = 600.0; // render target height
		
		extern number intensity = 1.0;

		const number offset[3] = number[](0.0, 1.3846153846, 3.2307692308);
		const number weight[3] = number[](0.2270270270, 0.3162162162, 0.0702702703);
		
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec4 texcolor = Texel(texture, texture_coords);
			vec3 tc = texcolor.rgb * weight[0];
			
			tc += Texel(texture, texture_coords + intensity * vec2(0.0, offset[1])/height).rgb * weight[1];
			tc += Texel(texture, texture_coords - intensity * vec2(0.0, offset[1])/height).rgb * weight[1];
			
			tc += Texel(texture, texture_coords + intensity * vec2(0.0, offset[2])/height).rgb * weight[2];
			tc += Texel(texture, texture_coords - intensity * vec2(0.0, offset[2])/height).rgb * weight[2];
			
			return color * vec4(tc, texcolor.a);
		}
	]]),
	horizontal = love.graphics.newShader([[
		extern number width = 800.0; // render target width
		
		extern number intensity = 1.0;

		const number offset[3] = number[](0.0, 1.3846153846, 3.2307692308);
		const number weight[3] = number[](0.2270270270, 0.3162162162, 0.0702702703);

		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec4 texcolor = Texel(texture, texture_coords);
			vec3 tc = texcolor.rgb * weight[0];
			
			tc += Texel(texture, texture_coords + intensity * vec2(offset[1], 0.0)/width).rgb * weight[1];
			tc += Texel(texture, texture_coords - intensity * vec2(offset[1], 0.0)/width).rgb * weight[1];
			
			tc += Texel(texture, texture_coords + intensity * vec2(offset[2], 0.0)/width).rgb * weight[2];
			tc += Texel(texture, texture_coords - intensity * vec2(offset[2], 0.0)/width).rgb * weight[2];
			
			return color * vec4(tc, texcolor.a);
		}
	]])

}

function shader.blur:setRenderTargetSize(width, height)
  self.vertical:send('height', height)
  self.horizontal:send('width', width)
end

function shader.blur:setIntensity(i)
  self.vertical:send('intensity', i)
  self.horizontal:send('intensity',i)
end

function shader.blur.setVertical()
  love.graphics.setShader(shader.blur.vertical)
end  

function shader.blur.setHorizontal()
  love.graphics.setShader(shader.blur.horizontal)
end  