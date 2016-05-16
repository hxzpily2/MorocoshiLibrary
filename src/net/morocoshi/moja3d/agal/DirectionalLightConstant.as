package net.morocoshi.moja3d.agal 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Light3D;
	
	use namespace moja3d;
	
	/**
	 * 平行光源のAGALコードを管理
	 * 
	 * @author tencho
	 */
	public class DirectionalLightConstant 
	{
		private var vertexAxis:AGALConstant;
		private var vertexColor:AGALConstant;
		private var fragmentAxis:AGALConstant;
		private var fragmentColor:AGALConstant;
		
		public function DirectionalLightConstant(index:int, vertexCode:AGALCode, fragmentCode:AGALCode) 
		{
			vertexAxis = vertexCode.addConstantsFromArray("@lightAxis" + index, [0, 0, 0, 0]);
			vertexColor = vertexCode.addConstantsFromArray("@lightColor" + index, [0, 0, 0, 0]);
			fragmentAxis = fragmentCode.addConstantsFromArray("@lightAxis" + index, [0, 0, 0, 0]);
			fragmentColor = fragmentCode.addConstantsFromArray("@lightColor" + index, [0, 0, 0, 0]);
		}
		
		public function dispose():void 
		{
			vertexAxis.dispose();
			vertexColor.dispose();
			fragmentAxis.dispose();
			fragmentColor.dispose();
			
			vertexAxis = null;
			vertexColor = null;
			fragmentAxis = null;
			fragmentColor = null;
		}
		
		public function clear():void
		{
			fragmentAxis.vector[0] = vertexAxis.vector[0] = 1;
			fragmentAxis.vector[1] = vertexAxis.vector[1] = 0;
			fragmentAxis.vector[2] = vertexAxis.vector[2] = 0;
			fragmentAxis.vector[3] = vertexAxis.vector[3] = 0;
			fragmentColor.vector[0] = vertexColor.vector[0] = 0;
			fragmentColor.vector[1] = vertexColor.vector[1] = 0;
			fragmentColor.vector[2] = vertexColor.vector[2] = 0;
			fragmentColor.vector[3] = vertexColor.vector[3] = 0;
		}
		
		public function applyFrom(light:Light3D):void 
		{
			//Z軸方向のベクトル
			var rawData:Vector.<Number> = light._worldMatrix.rawData;
			var axis:Vector3D = new Vector3D(rawData[8], rawData[9], rawData[10]);
			axis.normalize();
			
			fragmentAxis.vector[0] = vertexAxis.vector[0] = axis.x;
			fragmentAxis.vector[1] = vertexAxis.vector[1] = axis.y;
			fragmentAxis.vector[2] = vertexAxis.vector[2] = axis.z;
			fragmentAxis.vector[3] = vertexAxis.vector[3] = light.specularPower;
			fragmentColor.vector[0] = vertexColor.vector[0] = light.r;
			fragmentColor.vector[1] = vertexColor.vector[1] = light.g;
			fragmentColor.vector[2] = vertexColor.vector[2] = light.b;
			fragmentColor.vector[3] = vertexColor.vector[3] = light.intensity;
		}
		
		public function setFragmentEnabled(enabled:Boolean):void
		{
			fragmentAxis.enabled = enabled;
			fragmentColor.enabled = enabled;
		}
		
		public function setVertexEnabled(enabled:Boolean):void 
		{
			vertexAxis.enabled = enabled;
			vertexColor.enabled = enabled;
		}
		
	}

}