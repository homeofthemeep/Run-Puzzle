local kernelSetup =  {}
print("reached kernelSetup")

local function funcInit()
	print("Reached funcINit")
	local kernel = {category = "filter", name = "uv_scroll"}

	kernel.isTimeDependent = true

	kernel.fragment =  [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			uv.y -= (CoronaTotalTime/2.0);
			return texture2D(CoronaSampler0, uv);
		}

	]]


	local kernel2 = {category = "filter", name = "uv_scroll2"}

	kernel2.isTimeDependent = true

	kernel2.fragment =  [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			uv.y -= (CoronaTotalTime/2.25);
			return texture2D(CoronaSampler0, uv);
		}

	]]

	local kernel3 = {category = "filter", name = "uv_scroll3"}

	kernel3.isTimeDependent = true

	kernel3.fragment =  [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			uv.y -= (CoronaTotalTime/4.0);
			uv.x -= sin(CoronaTotalTime*1.0)/4.0;
			P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv);
			texColor.a = 0.25;
			return CoronaColorScale( texColor );
		}

	]]

	local kernel4 = {category = "filter", name = "uv_scroll4"}

	kernel4.isTimeDependent = true

	kernel4.fragment =  [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			uv.y -= (CoronaTotalTime/4.0);
			uv.x -= cos(CoronaTotalTime*1.0)/8.0;
			P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv);
			texColor.a = 0.25;
			return CoronaColorScale( texColor );
		}

	]]

	local kernel5 = {category = "filter", name = "uv_scroll5"}

	kernel5.isTimeDependent = true

	kernel5.fragment =  [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			uv.y -= (CoronaTotalTime/4.0);
			uv.x -= -sin(CoronaTotalTime*1.0)/8.0;
			P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv);
			texColor.a = 0.25;
			return CoronaColorScale( texColor );
		}

	]]

	graphics.defineEffect(kernel)
	graphics.defineEffect(kernel2)
	graphics.defineEffect(kernel3)
	graphics.defineEffect(kernel4)
	graphics.defineEffect(kernel5)

	display.setDefault( "textureWrapX", "repeat" )
	display.setDefault( "textureWrapY", "repeat" )
end

kernelSetup.funcInit = funcInit

return kernelSetup