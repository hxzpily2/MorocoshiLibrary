package net.morocoshi.moja3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.agal.UsingConstants;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MaterialShader
	{
		static private var shaderSeedCount:uint = 0;
		protected var _seed:uint;
		/**有効無効*/
		private var _enabled:Boolean;
		/***/
		public var valid:Boolean;
		/**頂点シェーダー*/
		public var vertexCode:AGALCode;
		/**フラグメントシェーダー*/
		public var fragmentCode:AGALCode;
		/**透過、不透過の区別*/
		public var alphaMode:uint;
		/**このシェーダーに鏡面反射要素があるか*/
		public var hasReflectElement:Boolean;
		/**このシェーダーに影投影要素があるか*/
		public var hasShadowElement:Boolean;
		/**このシェーダーに光投影要素があるか*/
		public var hasLightElement:Boolean;
		/**頂点シェーダー定数*/
		public var vertexConstants:UsingConstants;
		/**フラグメントシェーダー定数*/
		public var fragmentConstants:UsingConstants;
		/**シェーダーに必須の頂点アトリビュートのタイプ*/
		public var requiredAttribute:Vector.<uint>;
		
		moja3d var tickEnabled:Boolean;
		moja3d var lastFrame:int;
		moja3d var owners:Vector.<ShaderList>;
		
		public function MaterialShader() 
		{
			_seed = ++shaderSeedCount;
			lastFrame = -1;
			tickEnabled = false;
			_enabled = true;
			valid = true;
			hasReflectElement = false;
			hasShadowElement = false;
			hasLightElement = false;
			alphaMode = AlphaMode.NONE;
			vertexCode = new AGALCode(Context3DProgramType.VERTEX);
			fragmentCode = new AGALCode(Context3DProgramType.FRAGMENT);
			vertexConstants = new UsingConstants();
			fragmentConstants = new UsingConstants();
			owners = new Vector.<ShaderList>;
			requiredAttribute = new Vector.<uint>;
		}
		
		public function tick(time:int):void
		{
		}
		
		protected function updateAlphaMode():void
		{
			notifyChangeAlphaMode();
		}
		
		protected function updateTexture():void
		{
			vertexCode.clearTexture();
			fragmentCode.clearTexture();
			
			notifyChangeConstant();
		}
		
		protected function updateConstants():void
		{
			vertexCode.clearConstant();
			fragmentCode.clearConstant();
			
			notifyChangeConstant();
		}
		
		protected function updateShaderCode():void
		{
			vertexCode.clearCode();
			fragmentCode.clearCode();
			vertexConstants.clear();
			fragmentConstants.clear();
			
			notifyChangeConstant();
			notifyChangeReflection();
			notifyChangeShadow();
		}
		
		public function getKey():String
		{
			return String(this);
		}
		
		moja3d function addShaderListener(owner:ShaderList):void
		{
			var i:int = owners.indexOf(owner);
			if (i >= 0) return;
			
			owners.push(owner);
		}
		
		moja3d function removeShaderListener(owner:ShaderList):void
		{
			var i:int = owners.indexOf(owner);
			if (i == -1) return;
			
			owners.splice(i, 1);
		}
		
		private function notifyChangeAlphaMode():void
		{
			var n:int = owners.length;
			for (var i:int = 0; i < n; i++) 
			{
				owners[i].updateAlphaModeOrder = true;
				owners[i].updateKeyOrder = true;
			}
		}
		
		private function notifyChangeShadow():void
		{
			var n:int = owners.length;
			for (var i:int = 0; i < n; i++) 
			{
				owners[i].updatedShadowElement = true;
			}
		}
		
		private function notifyChangeReflection():void
		{
			var n:int = owners.length;
			for (var i:int = 0; i < n; i++) 
			{
				owners[i].updatedReflectElement = true;
			}
		}
		
		private function notifyChangeConstant():void
		{
			var n:int = owners.length;
			for (var i:int = 0; i < n; i++) 
			{
				owners[i].updateConstantOrder = true;
				owners[i].updateKeyOrder = true;
			}
		}
		
		public function clone():MaterialShader 
		{
			throw new Error("継承してください！");
			
			//var result:MaterialShader = new MaterialShader();
			//result.updateAlphaMode();
			//result.updateConstants();
			//result.updateShaderCode();
			//result.updateTexture();
			//cloneProperties(result);
			
			return null;
		}
		
		/**
		 * 深度テクスチャ生成時に利用するシェーダーリストに加えるシェーダーを生成する（必要ならoverride）
		 * @return
		 */
		public function getExtraShader(phase:String):MaterialShader 
		{
			return null;
		}
		
		/**
		 * Program3D生成後に一度だけ呼ばれる。キャッシュで生成がスキップされた場合も必ず1度は呼ばれる
		 * @param	vertexCode
		 * @param	fragmentCode
		 */
		public function afterCreateProgram(shaderList:ShaderList):void 
		{
		}
		
		public function calculate():void 
		{
			
		}
		
		public function draw():void 
		{
			
		}
		
		/**
		 * テクスチャ（ATF）の種類が更新された時などに呼び出す
		 */
		moja3d function updateTextureShaderCode():void 
		{
			updateShaderCode();
			updateAlphaMode();
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			updateShaderCode();
		}
		
		public function get seed():uint 
		{
			return _seed;
		}
		
		/**
		 * テクスチャサンプリングコード＜2d～＞の生成
		 * @param	smoothing	スムージング設定。Smoothingクラス参照
		 * @param	mipmap	ミップマップ設定。Mipmapクラス参照
		 * @param	tiling	タイリング設定。Tilingクラス参照
		 * @param	option	ATF用のオプション(dxt1,dxt5など)
		 * @return
		 */
		protected function getTextureTag(smoothing:String, mipmap:String, tiling:String, option:String):String
		{
			var samplingOption:String = option? ", " + option : "";
			return "<2d, " + mipmap + ", " + smoothing + ", " + tiling + samplingOption + ">";
		}
		
		/**
		 * テクスチャサンプリングコード＜cube～＞の生成
		 * @param	smoothing
		 * @param	mipmap
		 * @param	tiling
		 * @param	option
		 * @return
		 */
		protected function getCubeTextureTag(smoothing:String, mipmap:String, tiling:String, option:String):String
		{
			var samplingOption:String = option? ", " + option : "";
			return "<cube, " + smoothing + ", " + mipmap + ", " + tiling + samplingOption + ">";
		}
		
		/**
		 * テクスチャの種類が変化した際にシェーダーを再生成させるためのキャッシュ判別キー
		 * @param	texture
		 * @return
		 */
		protected function getSamplingKey(texture:AGALTexture):String 
		{
			return texture? texture.getSamplingOption() : "";
		}
		
		/*
		protected function cloneProperties(shader:MaterialShader):void
		{
			shader.fragmentCode = fragmentCode.clone();
			shader.vertexCode = vertexCode.clone();
			shader.fragmentConstants = fragmentConstants.clone();
			shader.vertexConstants = vertexConstants.clone();
			shader.hasReflectElement = hasReflectElement;
			shader.layer = layer;
		}
		*/
	}

}