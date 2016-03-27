package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 鏡面反射シェーダー
	 * $common.wをフレネル反射率として使用
	 * 
	 * @author tencho
	 */
	public class ReflectionShader extends MaterialShader 
	{
		private var _noize:Number;
		private var _blur:Number;
		private var _quality:int;
		private var _ratio:Number;
		private var _fresnel:Boolean;
		private var blurConst:AGALConstant;
		public var reflectionTexture:AGALTexture;
		
		/**
		 * 
		 * @param	ratio	基本反射率。1にすると元が半透明でも全反射する。fresnel=true時はこの値にフレネル反射率が乗算される
		 * @param	fresnel	フレネル反射率をratioに乗算するかどうか。事前にフレネルシェーダーを適用している必要がある。
		 * @param	noize	ノーマルマップによる反射画像の歪み量
		 * @param	blur	反射画像をぼかす場合の量。0でぼかさない。
		 * @param	quality	ぼかし品質。0で低品質。1で高品質。
		 */
		public function ReflectionShader(ratio:Number, fresnel:Boolean, noize:Number, blur:Number, quality:int) 
		{
			super();
			
			hasReflectElement = true;
			_ratio = ratio;
			_fresnel = fresnel;
			_blur = blur;
			_quality = quality;
			_noize = noize;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ReflectionShader:" + _quality + "," + String(_blur) + "," + String(_noize);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			reflectionTexture = fragmentCode.addTexture("&reflection", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			blurConst = fragmentCode.addConstantsFromArray("@blur", [_blur, _ratio, 0, _noize]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			
			fragmentCode.addCode([
				//基本UV
				"var $temp",
				"var $baseUV",
				"$baseUV.xy = #spos.xy / #spos.w",
				"$baseUV.xy *= @0.5",
				"$baseUV.xy += @0.5"
			])
			
			//法線による反射の歪み
			if (_noize > 0)
			{
				fragmentConstants.viewSize = true;
				fragmentConstants.viewMatrix = true;
			
				fragmentCode.addCode([
					"$temp.xyz = dp3($normal.xyz, @viewMatrix)",
					"$temp.xy /= @viewSize.zw",
					"$temp.xy *= @blur.ww",
					"$baseUV.xy += $temp.xy"
				])
			}
			
			var tag:String = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
			fragmentCode.addCode([
				"var $result",
				//基本画像
				"$result.xyz = tex($baseUV.xy, &reflection " + tag + ")"
			]);
			
			//ぼかし距離が0より上ならぼかし処理をいれる
			if (_blur > 0)
			{
				fragmentConstants.viewSize = true;
				
				//ぼかし処理
				fragmentCode.addCode([
					"var $uv2",
					
					//ぼかす距離
					"var $offset",
					"$offset.xy = @blur.x",
					"$offset.xy /= @viewSize.zw",
					"$offset.zw = $offset.xy * @0.5"
				]);
				
				var ofx:Array = ["- $offset.x", "- $offset.z", "", "+ $offset.z", "+ $offset.x"];
				var ofy:Array = ["- $offset.y", "- $offset.w", "", "+ $offset.w", "+ $offset.y"];
				
				if (_quality == 0)
				{
					ofx = ["- $offset.x", "", "+ $offset.x"];
					ofy = ["- $offset.y", "", "+ $offset.y"];
				}
				
				var total:Number = 1;
				var start:int = (_quality == 1)? 0 : 0;
				var end:int = (_quality == 1)? 4 : 2;
				for (var ix:int = start; ix <= end; ix++)
				for (var iy:int = start; iy <= end; iy++)
				{
					var num:Number = 1;
					tag = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
					fragmentCode.addCode([
						"$uv2.x = $baseUV.x" + ofx[ix],
						"$uv2.y = $baseUV.y" + ofy[iy],
						"$temp.xyz = tex($uv2.xy, &reflection " + tag + ")"
					]);
					/*
					if (ix == start || iy == start || ix == end || iy == end)
					{
						num = 0.5;
						fragmentCode.addCode("$temp.xyz *= @0.5");
					}
					*/
					fragmentCode.addCode(["$result.xyz += $temp.xyz"]);
					total ++;
				}
				blurConst.z = total;
				
				//加算数で割る
				fragmentCode.addCode(["$result.xyz /= @blur.z"]);
			}
			
			if (_fresnel)
			{
				fragmentCode.addCode(["$temp.w = @blur.y * $common.w"]);//元の反射率*フレネル反射
			}
			else
			{
				fragmentCode.addCode(["$temp.w = @blur.y"]);//元の反射率
			}
			
			//反射画像と元画像を反射率で合成（アルファも合成する）
			fragmentCode.addCode([
				"$temp.x = @1 - $temp.w",//1-最終反射率
				"$output.xyzw *= $temp.x",
				"$result.xyz *= $temp.w",
				"$result.w = $temp.w",
				"$output.xyzw += $result.xyzw"
			]);
		}
		
		public function get blur():Number 
		{
			return _blur;
		}
		
		public function set blur(value:Number):void 
		{
			if (_blur == value) return;
			
			_blur = value;
			blurConst.x = _blur;
		}
		
		public function get quality():int 
		{
			return _quality;
		}
		
		public function set quality(value:int):void 
		{
			if (_quality == value) return;
			
			_quality = value;
			updateShaderCode();
		}
		
		public function get noize():Number 
		{
			return _noize;
		}
		
		public function set noize(value:Number):void 
		{
			if (_noize == value) return;
			
			_noize = value;
			updateShaderCode();
		}
		
		public function get ratio():Number 
		{
			return _ratio;
		}
		
		public function set ratio(value:Number):void 
		{
			if (_ratio == value) return;
			
			_ratio = value;
			blurConst.y = _ratio;
		}
		
		public function get fresnel():Boolean 
		{
			return _fresnel;
		}
		
		public function set fresnel(value:Boolean):void 
		{
			_fresnel = value;
			updateShaderCode();
		}
		
		override public function clone():MaterialShader 
		{
			return new ReflectionShader(_ratio, _fresnel, _noize, _blur, _quality);
		}
		
	}

}