package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.OmniLight;
	
	use namespace moja3d;
	
	/**
	 * 点光源のAGALコードを管理
	 * 
	 * @author tencho
	 */
	public class OmniLightConstant 
	{
		private var vertexPosition:AGALConstant;
		private var vertexData:AGALConstant;
		private var vertexColor:AGALConstant;
		private var fragmentPosition:AGALConstant;
		private var fragmentData:AGALConstant;
		private var fragmentColor:AGALConstant;
		
		public function OmniLightConstant(index:int, vertexCode:AGALCode, fragmentCode:AGALCode) 
		{
			vertexPosition = vertexCode.addConstantsFromArray("@omniPosition" + index, [0, 0, 0, 0]);
			vertexData = vertexCode.addConstantsFromArray("@omniData" + index, [0, 0, 0, 0]);
			vertexColor = vertexCode.addConstantsFromArray("@omniColor" + index, [0, 0, 0, 0]);
			fragmentPosition = fragmentCode.addConstantsFromArray("@omniPosition" + index, [0, 0, 0, 0]);
			fragmentData = fragmentCode.addConstantsFromArray("@omniData" + index, [0, 0, 0, 0]);
			fragmentColor = fragmentCode.addConstantsFromArray("@omniColor" + index, [0, 0, 0, 0]);
		}
		
		public function clear():void
		{
			vertexPosition.vector[0] = fragmentPosition.vector[0] = 0;
			vertexPosition.vector[1] = fragmentPosition.vector[1] = 0;
			vertexPosition.vector[2] = fragmentPosition.vector[2] = 0;
			vertexPosition.vector[3] = fragmentPosition.vector[3] = 0;
			vertexData.vector[0] = fragmentData.vector[0] = 0;
			vertexData.vector[1] = fragmentData.vector[1] = 0;
			vertexData.vector[2] = fragmentData.vector[2] = 0;
			vertexData.vector[3] = fragmentData.vector[3] = 0;
			vertexColor.vector[0] = fragmentColor.vector[0] = 0;
			vertexColor.vector[1] = fragmentColor.vector[1] = 0;
			vertexColor.vector[2] = fragmentColor.vector[2] = 0;
			vertexColor.vector[3] = fragmentColor.vector[3] = 0;
		}
		
		public function applyFrom(light:OmniLight):void 
		{
			var rawData:Vector.<Number> = light._worldMatrix.rawData;
			fragmentPosition.vector[0] = vertexPosition.vector[0] = rawData[12];
			fragmentPosition.vector[1] = vertexPosition.vector[1] = rawData[13];
			fragmentPosition.vector[2] = vertexPosition.vector[2] = rawData[14];
			
			fragmentData.vector[0] = vertexData.vector[0] = light.fadeEnd;
			fragmentData.vector[1] = vertexData.vector[1] = light.fadeEnd - light.fadeStart;
			fragmentData.vector[2] = vertexData.vector[2] = light.specularPower;
			
			fragmentColor.vector[0] = vertexColor.vector[0] = light.r;
			fragmentColor.vector[1] = vertexColor.vector[1] = light.g;
			fragmentColor.vector[2] = vertexColor.vector[2] = light.b;
			fragmentColor.vector[3] = vertexColor.vector[3] = light.intensity;
		}
		
		public function setFragmentEnabled(enabled:Boolean):void
		{
			fragmentPosition.enabled = enabled;
			fragmentData.enabled = enabled;
			fragmentColor.enabled = enabled;
		}
		
		public function setVertexEnabled(enabled:Boolean):void 
		{
			vertexPosition.enabled = enabled;
			vertexData.enabled = enabled;
			vertexColor.enabled = enabled;
		}
		
	}

}