package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * 明暗を4段階のテクスチャで表現するトゥーンシェーダー。
	 * 明暗の決定にはシーン内の平行光源のみが使用されるが、光源の色は反映されない。
	 * トーンマップをそのまま反映したい場合は、シーン内の平行光源を1つ、強度は1にする。
	 * 
	 * @author tencho
	 */
	public class ToonTextureShader extends MaterialShader 
	{
		private var _mipmap:String;
		private var _smoothing:String;
		private var _tiling:String;
		private var diffuseTextures:Vector.<AGALTexture>;
		private var opacityTexture:AGALTexture;
		private var toneTexture:AGALTexture;
		
		/**
		 * 
		 * @param	diffuse1	テクスチャ画像リソース。トーンマップの赤成分が0xFFの範囲に割り当てられる。
		 * @param	diffuse2	テクスチャ画像リソース。トーンマップの赤成分が0xAAの範囲に割り当てられる。
		 * @param	diffuse3	テクスチャ画像リソース。トーンマップの赤成分が0x55の範囲に割り当てられる。
		 * @param	diffuse4	テクスチャ画像リソース。トーンマップの赤成分が0x00の範囲に割り当てられる。
		 * @param	opacity		不透明度マップ用画像リソース
		 * @param	toneMap		白黒のトーンマップ画像リソース。赤成分が0xFF,0xAA,0x55,0x00の階調がdiffuse1～4の画像に割り当てられる
		 * @param	mipmap
		 * @param	smoothing
		 * @param	tiling
		 */
		public function ToonTextureShader(diffuse1:TextureResource, diffuse2:TextureResource, diffuse3:TextureResource, diffuse4:TextureResource, opacity:TextureResource, toneMap:TextureResource, mipmap:String = "miplinear", smoothing:String = "linear", tiling:String = "wrap") 
		{
			super();
			
			diffuseTextures = new Vector.<AGALTexture>;
			_mipmap = mipmap;
			_smoothing = smoothing;
			_tiling = tiling;
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.diffuse1 = diffuse1;
			this.diffuse2 = diffuse2;
			this.diffuse3 = diffuse3;
			this.diffuse4 = diffuse4;
			this.opacity = opacity;
			this.toneMap = toneMap;
		}
		
		override public function getKey():String 
		{
			var key:String = "ToonTextureShader:";
			key += getSamplingKey(opacityTexture) + "_";
			key += getSamplingKey(diffuseTextures[0]) + "_";
			key += getSamplingKey(diffuseTextures[1]) + "_";
			key += getSamplingKey(diffuseTextures[2]) + "_";
			key += getSamplingKey(diffuseTextures[3]) + "_";
			key += _mipmap + "_" + _smoothing + "_" + _tiling;
			return key;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			var a0:Boolean = diffuseTextures[0].hasAlpha();
			var a1:Boolean = diffuseTextures[1].hasAlpha();
			var a2:Boolean = diffuseTextures[2].hasAlpha();
			var a3:Boolean = diffuseTextures[3].hasAlpha();
			alphaTransform = (opacity || a0 || a1 || a2 || a3)? AlphaTransform.SET_MIXTURE : AlphaTransform.SET_OPAQUE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			diffuseTextures.length = 0;
			diffuseTextures.push(fragmentCode.addTexture("&toonDiffuse0", null, this));
			diffuseTextures.push(fragmentCode.addTexture("&toonDiffuse1", null, this));
			diffuseTextures.push(fragmentCode.addTexture("&toonDiffuse2", null, this));
			diffuseTextures.push(fragmentCode.addTexture("&toonDiffuse3", null, this));
			opacityTexture = fragmentCode.addTexture("&toonOpacity", null, this);
			toneTexture = fragmentCode.addTexture("&toneMap", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			fragmentCode.addConstantsFromArray("@toneLevel", [85*3/0xff, 85*2/0xff, 85/0xff, 0x0/0xff]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			fragmentConstants.lights = true;
			fragmentConstants.cameraPosition = true;
			
			/*
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
			*/
			
			fragmentCode.addCode([
				"var $temp",
				"var $rgb",
				"$temp.x = @1",
				"$output.xyzw = @0_0_0_0",
				"$temp.x = @0"
			]);
			
			var tag:String;
			//平行光源を加算
			if (LightSetting._numDirectionalLights > 1)
			{
				diffuseTextures[0].enabled = true;
				diffuseTextures[1].enabled = true;
				diffuseTextures[2].enabled = true;
				diffuseTextures[3].enabled = true;
				toneTexture.enabled = true;
				for (var j:int = 0; j < LightSetting._numDirectionalLights; j++) 
				{
					var lightAxis:String = "@lightAxis" + j;
					var lightColor:String = "@lightColor" + j;
					fragmentCode.addCode([
						"$temp.w = dp3($normal.xyz, " + lightAxis + ".xyz)",//ライトの向きとのドット積
						"$temp.w *= @0.5",
						"$temp.w += @0.5",
						"$temp.w *= " + lightColor + ".w",
						"$temp.x = max($temp.x, $temp.w)"
					]);
				}
				tag = toneTexture.getOption2D(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP);
				fragmentCode.addCode([
					//"$temp.x = sat($temp.x)",//0～1にする
					"$temp.xyz = tex($temp.xx, &toneMap " + tag + ")"
				]);
				
				for (var i:int = 0; i < 4; i++) 
				{
					tag = diffuseTextures[i].getOption2D(_smoothing, _mipmap, _tiling);
					fragmentCode.addCode([
						"$rgb.xyzw = tex(#uv, &toonDiffuse" + i + " " + tag + ")",
						"$temp.y = $temp.x - @toneLevel." + ["x", "y", "z", "w"][i],
						"$temp.y = abs($temp.y)",
						"$temp.y /= @toneLevel.z",
						"$temp.y = sat($temp.y)",
						"$temp.y = @1 - $temp.y",
						"$rgb.xyzw *= $temp.yyyy",
						"$output.xyzw += $rgb.xyzw"
					]);
				}
			}
			else
			{
				diffuseTextures[0].enabled = !false;
				diffuseTextures[1].enabled = false;
				diffuseTextures[2].enabled = false;
				diffuseTextures[3].enabled = false;
				toneTexture.enabled = false;
				tag = diffuseTextures[i].getOption2D(_smoothing, _mipmap, _tiling);
				fragmentCode.addCode([
					"$output.xyzw = tex(#uv, &toonDiffuse0 " + tag + ")"
				]);
			}
			
			if (opacity)
			{
				opacityTexture.enabled = true;
				tag = opacityTexture.getOption2D(_smoothing, _mipmap, _tiling);
				fragmentCode.addCode([
					"$temp.xyz = tex(#uv, &toonOpacity " + tag + ")",
					"$output.w *= $temp.x"
				]);
			}
			else
			{
				opacityTexture.enabled = false;
			}
		}
		
		override public function reference():MaterialShader 
		{
			return new ToonTextureShader(diffuse1, diffuse2, diffuse3, diffuse4, opacity, toneMap, _mipmap, _smoothing, _tiling);
		}
		
		override public function clone():MaterialShader 
		{
			var r1:ImageTextureResource = cloneTexture(diffuse1) as ImageTextureResource;
			var r2:ImageTextureResource = cloneTexture(diffuse2) as ImageTextureResource;
			var r3:ImageTextureResource = cloneTexture(diffuse3) as ImageTextureResource;
			var r4:ImageTextureResource = cloneTexture(diffuse4) as ImageTextureResource;
			var r5:ImageTextureResource = cloneTexture(opacity) as ImageTextureResource;
			var r6:ImageTextureResource = cloneTexture(toneMap) as ImageTextureResource;
			return new ToonTextureShader(r1, r2, r3, r4, r5, r6, _mipmap, _smoothing, _tiling);
		}
		
		public function get diffuse1():TextureResource { return diffuseTextures[0].texture; }
		public function get diffuse2():TextureResource { return diffuseTextures[1].texture; }
		public function get diffuse3():TextureResource { return diffuseTextures[2].texture; }
		public function get diffuse4():TextureResource { return diffuseTextures[3].texture; }
		public function set diffuse1(value:TextureResource):void { diffuseTextures[0].texture = value; }
		public function set diffuse2(value:TextureResource):void { diffuseTextures[1].texture = value; }
		public function set diffuse3(value:TextureResource):void { diffuseTextures[2].texture = value; }
		public function set diffuse4(value:TextureResource):void { diffuseTextures[3].texture = value; }
		public function get toneMap():TextureResource { return toneTexture.texture; }
		public function set toneMap(value:TextureResource):void
		{
			toneTexture.texture = value;
		}
		public function get opacity():TextureResource { return opacityTexture.texture; }
		public function set opacity(value:TextureResource):void
		{
			opacityTexture.texture = value;
			updateAlphaMode();
			updateShaderCode();
		}
		
		public function get mipmap():String 
		{
			return _mipmap;
		}
		
		public function set mipmap(value:String):void 
		{
			if (_mipmap == value) return;
			
			_mipmap = value;
			updateShaderCode();
		}
		
		public function get smoothing():String 
		{
			return _smoothing;
		}
		
		public function set smoothing(value:String):void 
		{
			if (_smoothing == value) return;
			
			_smoothing = value;
			updateShaderCode();
		}
		
		public function get tiling():String 
		{
			return _tiling;
		}
		
		public function set tiling(value:String):void 
		{
			if (_tiling == value) return;
			
			_tiling = value;
			updateShaderCode();
		}
		
	}

}