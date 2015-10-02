package net.morocoshi.moja3d.agal 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Light3D;
	import net.morocoshi.moja3d.objects.Shadow;
	
	use namespace moja3d;
	
	/**
	 * 影のAGALコードを管理
	 * 
	 * @author tencho
	 */
	public class ShadowConstant 
	{
		public var shadowMainViewConst:AGALConstant;
		public var shadowWideViewConst:AGALConstant;
		public var fragmentMainTexture:AGALTexture;
		public var fragmentWideTexture:AGALTexture;
		public var fragmentConst:AGALConstant;
		public var useWideShadow:Boolean;
		
		public function ShadowConstant(index:int, vertexCode:AGALCode, fragmentCode:AGALCode) 
		{
			shadowMainViewConst = vertexCode.addConstantsFromMatrix("@shadowViewMatrix" + index + "_0", new Matrix3D(), true);
			shadowWideViewConst = vertexCode.addConstantsFromMatrix("@shadowViewMatrix" + index + "_1", new Matrix3D(), true);
			fragmentConst = fragmentCode.addConstantsFromArray("@shadow" + index, [0, 0, 0, 0]);
			fragmentMainTexture = fragmentCode.addTexture("&shadowMap" + index + "_0", null, null);
			fragmentWideTexture = fragmentCode.addTexture("&shadowMap" + index + "_1", null, null);
		}
		
		public function clear():void
		{
			fragmentConst.x = 0;
		}
		
		/**
		 * Shadowのパラメータを調べて定数に反映する
		 * @param	shadow
		 * @param	phase
		 */
		public function applyFrom(light:Light3D):void 
		{
			var mainShadow:Shadow = light._mainShadow;
			var wideShadow:Shadow = light._wideShadow;
			
			shadowMainViewConst.matrix.copyFrom(mainShadow.viewMatrix);
			shadowMainViewConst.matrix.append(mainShadow.perspectiveMatrix);
			fragmentMainTexture.texture = mainShadow.shadowTexture;
			useWideShadow = (wideShadow != null);
			if (useWideShadow)
			{
				shadowWideViewConst.matrix.copyFrom(wideShadow.viewMatrix);
				shadowWideViewConst.matrix.append(wideShadow.perspectiveMatrix);
				fragmentWideTexture.texture = wideShadow.shadowTexture;
			}
			else
			{
				fragmentWideTexture.texture = null;
			}
			
			fragmentConst.x = mainShadow.intensity;
		}
		
		public function setFragmentEnabled(enabled:Boolean):void
		{
			fragmentConst.enabled = enabled;
			fragmentMainTexture.enabled = enabled;
			fragmentWideTexture.enabled = enabled && useWideShadow;
		}
		
		public function setVertexEnabled(enabled:Boolean):void 
		{
			shadowMainViewConst.enabled = enabled;
			shadowWideViewConst.enabled = enabled;
		}
		
	}

}