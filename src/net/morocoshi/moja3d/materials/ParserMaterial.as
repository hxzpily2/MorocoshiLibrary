package net.morocoshi.moja3d.materials 
{
	import net.morocoshi.moja3d.animation.KeyframeAnimation;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.shaders.render.AlphaShader;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.LambertShader;
	import net.morocoshi.moja3d.shaders.render.NormalMapShader;
	import net.morocoshi.moja3d.shaders.render.OpacityShader;
	import net.morocoshi.moja3d.shaders.render.TextureShader;
	import net.morocoshi.moja3d.shaders.render.VertexColorShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParserMaterial extends Material 
	{
		/**マテリアルアニメーション*/
		public var animation:KeyframeAnimation;
		/**パースに使用した各種マテリアル情報*/
		public var rawData:M3DMaterial;
		
		/**
		 * 
		 * @param	rawData
		 * @param	animation
		 */
		public function ParserMaterial(rawData:M3DMaterial, animation:KeyframeAnimation) 
		{
			super();
			
			this.rawData = rawData;
			this.animation = animation;
			
			name = rawData.name;
			culling = rawData.doubleSided? TriangleFace.BOTH : TriangleFace.FRONT;
			blendMode = rawData.blendMode;
			
			attachDefaultShader();
		}
		
		/**
		 * M3DMaterialの情報から適当にシェーダーを設定する
		 */
		public function attachDefaultShader():void 
		{
			addAnimationShader();
			addTextureShader();
			addNormalMapShader(1);
			shaderList.addShader(new VertexColorShader());
			shaderList.addShader(new LambertShader());
		}
		
		/**
		 * もしあれば、アニメーション用のシェーダーを追加します。
		 */
		public function addAnimationShader():void
		{
			if (animation)
			{
				shaderList.addShader(animation.uvOffsetShader);
			}
		}
		
		/**
		 * 基本色、基本テクスチャのシェーダーを追加します。
		 */
		public function addTextureShader():void
		{
			var opacityResource:ExternalTextureResource = rawData.opacityPath? new ExternalTextureResource(rawData.opacityPath) : null;
			var smoothing:String = rawData.smoothing? Smoothing.LINEAR : Smoothing.NEAREST;
			if (rawData.diffusePath)
			{
				var diffuseResource:ExternalTextureResource = new ExternalTextureResource(rawData.diffusePath);
				shaderList.addShader(new TextureShader(diffuseResource, opacityResource, rawData.mipmap, smoothing, rawData.tiling));
				if (rawData.alpha < 1)
				{
					shaderList.addShader(new AlphaShader(rawData.alpha));
				}
			}
			else
			{
				shaderList.addShader(new FillShader(rawData.diffuseColor, rawData.alpha));
				if (opacityResource)
				{
					shaderList.addShader(new OpacityShader(opacityResource, rawData.mipmap, smoothing, rawData.tiling));
				}
			}
		}
		
		/**
		 * もしあれば、ノーマルマップシェーダーを追加します
		 */
		public function addNormalMapShader(scale:Number = 1):void
		{
			if (rawData.normalPath)
			{
				var normalResource:ExternalTextureResource = new ExternalTextureResource(rawData.normalPath);
				shaderList.addShader(new NormalMapShader(normalResource, scale));
			}
		}
		
	}

}