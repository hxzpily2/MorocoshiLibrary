package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * 
	 * @author tencho
	 */
	public class ToonShader extends MaterialShader 
	{
		private var _resource:ImageTextureResource;
		private var _useLightMap:Boolean;
		private var _outlineEnabled:Boolean;
		private var _outlineAngle:Number;
		private var _outlineColor:uint;
		private var toonTexture:AGALTexture;
		private var outlineConst:AGALConstant;
		
		public function ToonShader(resource:ImageTextureResource, outlineEnabled:Boolean = true, outlineAngle:Number = 80, outlineColor:uint = 0x000000, useLightMap:Boolean = false) 
		{
			super();
			
			_resource = resource;
			_useLightMap = useLightMap;
			_outlineAngle = outlineAngle;
			_outlineEnabled = outlineEnabled;
			_outlineColor = outlineColor;
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ToonShader:" + int(_outlineEnabled);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			toonTexture = fragmentCode.addTexture("&toon", _resource, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			outlineConst = fragmentCode.addConstantsFromColor("@toonOutline", _outlineColor, _outlineAngle / 90 - 1);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			fragmentConstants.ambient = true;
			fragmentConstants.lights = true;
			fragmentConstants.cameraPosition = true;
			
			var toonTag:String = getTextureTag(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP, toonTexture.getSamplingOption());
			
			fragmentCode.addCode([
				"var $total",
				"var $brightness",
				"var $temp",
				
				//環境光を加算
				"$total.w = @1",
				"$brightness.w = @1",
				"$total.xyz = @ambientColor.xyz",
				"$total.xyz *= @ambientColor.www"
			]);
			
			var i:int;
			//点光源を加算
			for (i = 0; i < LightSetting._numOmniLights; i++)
			{
				var omniPosition:String = "@omniPosition" + i;
				var omniData:String = "@omniData" + i;
				var omniColor:String = "@omniColor" + i;
				fragmentCode.addCode([
					"$temp.xyz = " + omniPosition + ".xyz - #wpos.xyz",
					"$temp.xyz = pow($temp.xyz, @2)",
					"$temp.x += $temp.y",
					"$temp.x += $temp.z",
					"$temp.x = sqt($temp.x)",
					"$temp.x = " + omniData + ".x - $temp.x",
					"$temp.x /= " + omniData + ".y",
					"$temp.x = sat($temp.x)",
					
					"$brightness.xyz = " + omniPosition + ".xyz",
					"$brightness.xyz -= #wpos.xyz",
					"$brightness.xyz = nrm($brightness.xyz)",
					"$brightness.x = dp3($normal.xyz, $brightness.xyz)",//ライトの向きとのドット積
					"$brightness.x = sat($brightness.x)",//0～1にする
					"$brightness.xyz = tex($brightness.xx, &toon " + toonTag + ")",
					"$brightness.xyz *= $temp.xxx",//距離による強度
					"$brightness.xyz *= " + omniColor + ".xyz",//明るさに光源カラーを乗算
					"$brightness.xyz *= " + omniColor + ".www"//明るさに光源強度を乗算
				])
				//もし点光源の影を実装したらここに挿入する
				fragmentCode.addCode(["$total.xyz += $brightness.xyz"]);
			}
			
			//平行光源を加算
			for (i = 0; i < LightSetting._numDirectionalLights; i++) 
			{
				var lightAxis:String = "@lightAxis" + i;
				var lightColor:String = "@lightColor" + i;
				fragmentCode.addCode([
					"$brightness.x = dp3($normal.xyz, " + lightAxis + ".xyz)",//ライトの向きとのドット積
					"$brightness.x *= @0.5",
					"$brightness.x += @0.5",
					"$brightness.x = sat($brightness.x)",//0～1にする
					"$brightness.xyz = tex($brightness.xx, &toon " + toonTag + ")",
					"$brightness.xyz *= " + lightColor + ".xyz",//明るさに光源カラーを乗算
					"$brightness.xyz *= " + lightColor + ".www"//明るさに光源強度を乗算
				])
				if (i < 2)
				{
					var xyz1:String = ["x", "y"][i];
					fragmentCode.addCode(["$brightness.xyz *= $common." + xyz1])//明るさに影の強度を乗算
				}
				fragmentCode.addCode(["$total.xyz += $brightness.xyz"]);
			}
			
			if (_useLightMap)
			{
				fragmentCode.addCode(["$total.xyz += $common.zzz"]);
			}
			
			fragmentCode.addCode(["$output.xyz *= $total.xyz"]);
			
			if (_outlineEnabled)
			{
				fragmentCode.addCode([
					"var $eye",
					//視点からテクセルへのベクトル
					"$eye.xyz = #wpos.xyz - @cameraPosition.xyz",
					"$eye.xyz = nrm($eye.xyz)",
					"$eye.x = dp3($normal.xyz, $eye.xyz)",
					"$eye.x = sge($eye.x, @toonOutline.w)",
					"$eye.y = @1 - $eye.x",
					"$output.xyz *= $eye.yyy",
					"$temp.xyz = @toonOutline.xyz",
					"$temp.xyz *= $eye.xxx",
					"$output.xyz += $temp.xyz"
				]);
			}
		}
		
		override public function reference():MaterialShader 
		{
			return new ToonShader(_resource, _outlineEnabled, _outlineAngle, _outlineColor,_useLightMap);
		}
		
		override public function clone():MaterialShader 
		{
			return new ToonShader(cloneTexture(_resource) as ImageTextureResource, _outlineEnabled, _outlineAngle, _outlineColor, _useLightMap);
		}
		
		public function get useLightMap():Boolean 
		{
			return _useLightMap;
		}
		
		public function set useLightMap(value:Boolean):void 
		{
			_useLightMap = value;
			updateShaderCode();
		}
		
		public function get resource():ImageTextureResource 
		{
			return _resource;
		}
		
		public function set resource(value:ImageTextureResource):void 
		{
			toonTexture.setTexture(_resource = value);
		}
		
		public function get outlineEnabled():Boolean 
		{
			return _outlineEnabled;
		}
		
		public function set outlineEnabled(value:Boolean):void 
		{
			_outlineEnabled = value;
			updateShaderCode();
		}
		
		public function get outlineAngle():Number 
		{
			return _outlineAngle;
		}
		
		public function set outlineAngle(value:Number):void 
		{
			_outlineAngle = value;
			outlineConst.w = _outlineAngle / 90 - 1;
		}
		
		public function get outlineColor():uint 
		{
			return _outlineColor;
		}
		
		public function set outlineColor(value:uint):void 
		{
			_outlineColor = value;
			outlineConst.setRGB(_outlineColor);
		}
		
	}

}