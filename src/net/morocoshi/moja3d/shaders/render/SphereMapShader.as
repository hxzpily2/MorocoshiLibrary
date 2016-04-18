package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 球状環境マップ
	 * 
	 * @author tencho
	 */
	public class SphereMapShader extends MaterialShader 
	{
		private var _alpha:Number;
		private var _blendMode:String;
		private var _strict:Boolean;
		private var _applyNormal:Boolean;
		private var blendConst:AGALConstant;
		private var texture:AGALTexture;
		
		public function SphereMapShader(resource:TextureResource, alpha:Number, blendMode:String, strict:Boolean, applyNormal:Boolean) 
		{
			super();
			
			_alpha = alpha;
			_strict = strict;
			_blendMode = blendMode;
			_applyNormal = applyNormal;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function getKey():String 
		{
			return "SphereMapShader:" + _blendMode + _strict + _applyNormal;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			texture = fragmentCode.addTexture("&sphere", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			blendConst = fragmentCode.addConstantsFromArray("@sphereBlend");
			updateBlendAlpha();
		}
		
		private function updateBlendAlpha():void 
		{
			blendConst.x = _alpha;
			blendConst.y = 1 - _alpha;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			if (_strict)
			{
				strictCode();
			}
			else
			{
				simpleCode();
			}
		}
		
		private function simpleCode():void
		{
			if (_applyNormal == false)
			{
				vertexConstants.viewMatrix = true;
				vertexCode.addCode([
					"var $cameraNormal",
					"$cameraNormal.xyz = m33($normal.xyz, @viewMatrix)",//カメラ行列でワールド法線を変換
					"$cameraNormal.xyz = nrm($cameraNormal.xyz)",
					"#cameraNormal = $cameraNormal"//視線空間での法線
				]);
			}
			
			fragmentConstants.number = true;
			
			if (_applyNormal)
			{
				fragmentConstants.viewMatrix = true;
			}
			
			fragmentCode.addCode(["var $cameraNormal"]);
			
			var code:String = _applyNormal? "m33($normal.xyz, @viewMatrix)" : "#cameraNormal.xyz";
			var tag:String = texture.getOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
			fragmentCode.addCode([
				"$cameraNormal.xyz = " + code,
				"$cameraNormal.xyz = nrm($cameraNormal.xyz)",
				"$cameraNormal.xy *= @0.5_0.5",
				"$cameraNormal.xy = neg($cameraNormal.xy)",
				"$cameraNormal.xy += @0.5_0.5",
				"var $env",
				"$env = tex($cameraNormal.xy, &sphere " + tag + ")"
			]);
			
			if (_blendMode == BlendMode.ADD)
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$output.xyz += $env.xyz"
				]);
			}
			else if (_blendMode == BlendMode.MULTIPLY)
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$env.xyz += @sphereBlend.yyy",
					"$output.xyz *= $env.xyz"
				]);
			}
			else
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$output.xyz *= @sphereBlend.yyy",
					"$output.xyz += $env.xyz"
				]);
			}
		}
		
		private function strictCode():void 
		{
			//R = 2 * N * (NL) - L
			
			//M = 2 * sqrt(r.x ^ 2 + r.y ^ 2 + (r.z + 1) ^ 2)
			//U = r.x / M + 0.5
			//V = r.y / M + 0.5
			
			//頂点シェーダー
			vertexCode.addCode([
				"var $cameraNormal",
				"$cameraNormal.xyz = m33($normal.xyz, @viewMatrix)",//カメラ行列でワールド法線を変換
				"$cameraNormal.xyz = nrm($cameraNormal.xyz)",
				"#cameraNormal = $cameraNormal"//カメラ空間での法線
			]);
			
			//フラグメントシェーダー
			fragmentCode.addCode([
				"var $cameraNormal",
				"$cameraNormal.xyz = nrm(#cameraNormal.xyz)",
				"$cameraNormal.xy = neg($cameraNormal.xy)",
				//テクセルから視線へのベクトル（正規化）
				"var $eye",
				"$eye.xyz = #vpos.xyz",
				//"$eye.xyz = nrm($eye.xyz)",
				
				//反射ベクトルを求める
				"var $ref",
				"$ref.w = dp3($eye.xyz, $cameraNormal.xyz)",//dot(EYE*NORMAL)
				"$ref.xyz = $cameraNormal.xyz * $ref.www",//xNORMAL
				"$ref.xyz *= @2",
				"$ref.xyz = $eye.xyz - $ref.xyz",
				"$ref.xyz = nrm($ref.xyz)",
				
				//係数Mを求める : sqrt(x^2+y^2+(z+1)^2)*2
				"var $m",
				"$m.xyz = $ref.xyz",
				"$m.z -= @1",
				"$m.xyz = pow($m.xyz, @2)",
				"$m.w = $m.x + $m.y",
				"$m.w += $m.z",
				"$m.w = sqt($m.w)",
				"$m.w *= @2",
				
				"$ref.xy /= $m.ww",
				"$ref.xy += @0.5_0.5",
				
				"var $env",
				"$env = tex($ref.xy, &sphere <2d, linear, nomip, wrap>)"
			]);
			
			if (_blendMode == BlendMode.ADD)
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$output.xyz += $env.xyz"
				]);
			}
			else if (_blendMode == BlendMode.MULTIPLY)
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$env.xyz += @sphereBlend.yyy",
					"$output.xyz *= $env.xyz"
				]);
			}
			else
			{
				fragmentCode.addCode([
					"$env.xyz *= @sphereBlend.xxx",
					"$output.xyz *= @sphereBlend.yyy",
					"$output.xyz += $env.xyz"
				]);
			}
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			updateBlendAlpha();
		}
		
		public function get blendMode():String 
		{
			return _blendMode;
		}
		
		public function set blendMode(value:String):void 
		{
			if (_blendMode == value) return;
			
			_blendMode = value;
			updateShaderCode();
		}
		
		public function get strict():Boolean 
		{
			return _strict;
		}
		
		public function set strict(value:Boolean):void 
		{
			if (_strict == value) return;
			
			_strict = value;
			updateShaderCode();
		}
		
		public function get applyNormal():Boolean 
		{
			return _applyNormal;
		}
		
		public function set applyNormal(value:Boolean):void 
		{
			_applyNormal = value;
			updateShaderCode();
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
		override public function reference():MaterialShader 
		{
			return new SphereMapShader(resource, _alpha, _blendMode, _strict, _applyNormal);
		}
		
		override public function clone():MaterialShader 
		{
			return new SphereMapShader(cloneTexture(resource), _alpha, _blendMode, _strict, _applyNormal);
		}
		
	}

}