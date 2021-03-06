package net.morocoshi.moja3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.agal.UsingConstants;
	import net.morocoshi.moja3d.resources.TextureAtlasResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	
	use namespace moja3d;
	
	/**
	 * シェーダーの基本クラス
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
		public var alphaTransform:uint;
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
		
		moja3d var owners:Vector.<ShaderList>;
		//描画毎にtick()を呼び出す対象かどうか
		moja3d var tickEnabled:Boolean;
		//描画毎tick用
		moja3d var lastFrame:int;
		
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
			alphaTransform = AlphaTransform.UNCHANGE;
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
			throw new Error("継承してください！");
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
		
		public function reference():MaterialShader
		{
			return clone();
		}
		
		public function clone():MaterialShader 
		{
			throw new Error("継承してください！");
			return null;
		}
		
		protected function cloneTexture(resource:TextureResource):TextureResource 
		{
			return resource? resource.clone() as TextureResource : null;
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
		
		moja3d function updateTextureAlphaMode():void
		{
			updateAlphaMode();
		}
		
		/**
		 * テクスチャ（ATF）の種類が更新された時などに呼び出す
		 */
		moja3d function updateTextureShaderCode():void 
		{
			updateShaderCode();
		}
		
		/**
		 * シェーダーが有効かどうか。これを弄るとこのシェーダーの有無を反映した新しいProgram3Dが再生成されるので負荷に注意。
		 * TODO: 一部のシェーダーで切り替え時におかしくなるバグがあるので要対応。
		 */
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			updateShaderCode();
		}
		
		/**
		 * シェーダーのインスタンスごとに違うシード値
		 */
		public function get seed():uint 
		{
			return _seed;
		}
		
		/**
		 * テクスチャの種類が変化した際にシェーダーを再生成させるためのキャッシュ判別キー
		 * @param	texture
		 * @return
		 */
		protected function getSamplingKey(texture:AGALTexture):String 
		{
			return texture? texture.enabled? texture.getSamplingOption() + "-" + int(texture.texture is TextureAtlasResource) : "!" : "";
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